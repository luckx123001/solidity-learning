// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract MultiSigWallet {
    address[] public owners; // 所有者列表
    //用于快速确认是否是owner，如果不做这个映射，则需要遍历上面的owners数组，遍历是很费gas的操作
    mapping(address => bool) public isOwner; // 记录是否是所有者的映射
    uint public numConfirmationsRequired; // 所需确认数量
    uint public maxTransactionAmount; // 最大交易金额限制
    uint public transactionTimeout; // 交易确认超时时间
    //用于记录某个transaction被哪些地址approve了， transactionid => (address => bool)
    mapping(uint => mapping(address => bool)) isConfirmed;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations;
        uint confirmationTime;
    }

    Transaction[] public transactions; // 交易列表
    mapping(uint => uint) public transactionNonce; // 交易nonce映射，防止重放攻击
    mapping(uint => bool) public revokedTransactions; // 撤销交易标记

    event Deposit(address indexed sender, uint value); // 存款事件
    event Submission(uint indexed transactionId, uint nonce); // 提交交易事件
    event Confirmation(address indexed sender, uint indexed transactionId); // 确认交易事件
    event Execution(uint indexed transactionId); // 执行交易事件
    event ExecutionFailure(uint indexed transactionId); // 执行交易失败事件
    event TransactionRevoked(uint indexed transactionId); // 撤销交易事件

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not an owner");
        _;
    }

    modifier validTransaction(uint _transactionId) {
        require(_transactionId < transactions.length, "Transaction not found");
        require(!transactions[_transactionId].executed, "Transaction already executed");
        require(!revokedTransactions[_transactionId], "Transaction revoked");
        _;
    }

    constructor(address[] memory _owners, uint _numConfirmationsRequired, uint _maxTransactionAmount, uint _transactionTimeout) {
        require(_owners.length > 0, "Owners required");
        require(_numConfirmationsRequired > 0 && _numConfirmationsRequired <= _owners.length, "Invalid confirmations");
        require(_maxTransactionAmount > 0, "Max transaction amount must be greater than 0");
        require(_transactionTimeout > 0, "Transaction timeout must be greater than 0");

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            // require(!isOwner[owner], "Duplicate owner");
            if (!isOwner[owner]) {
                isOwner[owner] = true;
                owners.push(owner);
            }
        }

        numConfirmationsRequired = _numConfirmationsRequired;
        maxTransactionAmount = _maxTransactionAmount;
        transactionTimeout = _transactionTimeout;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function submitTransaction(address _to, uint _value, bytes memory _data) public onlyOwner {
        require(_value <= maxTransactionAmount, "Exceeds max transaction amount");

        uint transactionId = transactions.length;
        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            numConfirmations: 0,
            confirmationTime: block.timestamp
        }));

        emit Submission(transactionId, transactionNonce[transactionId]);
        transactionNonce[transactionId]++;
    }

    function confirmTransaction(uint _transactionId) public onlyOwner validTransaction(_transactionId) {
        require(!isConfirmed[_transactionId][msg.sender], "duplicate confirm");
        //当前调用者批准某笔交易
        isConfirmed[_transactionId][msg.sender] = true;
        //该笔交易批准数量+1
        transactions[_transactionId].numConfirmations++;
        //发送事件，记录日志
        emit Confirmation(msg.sender, _transactionId);

        if (transactions[_transactionId].numConfirmations >= numConfirmationsRequired) {
            executeTransaction(_transactionId);
        }
    }

    function executeTransaction(uint _transactionId) public payable onlyOwner validTransaction(_transactionId) {
        Transaction storage transaction = transactions[_transactionId];
        require(block.timestamp < transaction.confirmationTime + transactionTimeout, "Transaction expired");
        require(transactions[_transactionId].numConfirmations >= numConfirmationsRequired, "need more confirm");
        transaction.executed = true;
        //发送主币，方法必须用payable修饰
        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        if (success) {
            emit Execution(_transactionId);
        } else {
            emit ExecutionFailure(_transactionId);
            transaction.executed = false;
        }
    }

    function revokeTransaction(uint _transactionId) public onlyOwner validTransaction(_transactionId) {
        revokedTransactions[_transactionId] = true;
        emit TransactionRevoked(_transactionId);
    }

    function getTransactionCount() public view returns (uint) {
        return transactions.length;
    }

    function getTransaction(uint _transactionId) public view returns (address to, uint value, bytes memory data, bool executed, uint numConfirmations, uint confirmationTime) {
        Transaction storage transaction = transactions[_transactionId];
        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations,
            transaction.confirmationTime
        );
    }

    function isTransactionConfirmed(uint _transactionId) public view returns (bool) {
        return transactions[_transactionId].numConfirmations >= numConfirmationsRequired;
    }

    function getBalance() external view returns(uint) {
        return address(this).balance;
    }
}
