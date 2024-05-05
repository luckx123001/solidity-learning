// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

contract SendEther {

    //将构造函数加上payable，则在部署该合约时，就可以通过msg.value来发送eth
    constructor() payable {
    }

    receive() external payable { }

    
    function sendViaTransfer(address payable _to) external payable {
        //这里的_to必须标记为payable，才有发送eth的功能，否则报错，这里的123是指123wei
        _to.transfer(123);
    }

    function sendViaSend(address payable _to) external payable {
        //send方法会返回一个bool变量的值，true表示发送成功，false表示发送失败
        bool success = _to.send(123);
        require(success, "send failed");
    }

    function sendViaCall(address payable _to) external payable {
        //这里的语法很怪，value值表示要发送的值，此处为123wei，""为data，在接收方看来，就是msg.data
        //call方法会返回两个值，第1个为bool，标记是否成功，第2个为data
        (bool success,) = _to.call{value: 123}("");
        require(success, "call failed");
    }

    //获取当前合约的主币余额
    function getBalance() external view returns(uint) {
        return address(this).balance;
    }
}

contract ReceiverEther {

    function getBalance() external view returns(uint) {
        return address(this).balance;
    }

    event Log(uint amount, uint gas);

    receive() external payable { 
        emit Log(msg.value, gasleft());
    }
}

//具有存款取款功能，但只限定合约部署者有取款权限
contract EtherWallet {

    address private owner;

    constructor() {
        owner = msg.sender;
    }

    //如果是通过js client调用的话，格式为：contract.withdraw(100,{value:100})
    function withdraw(uint _amount) external payable {
        require(msg.sender == owner, "caller is not owner");
        //存多少，取多少，一滴都不剩
        require(msg.value == _amount, "balance not enough");
        emit Log(address(this), getBalance(), "call from withdraw");
        //从当前合约账户(EtherWallet)的余额中转账到owner地址，数量为_amount
        payable(msg.sender).transfer(_amount);
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    event Log(address contractAddress, uint value, string desc);

    //让EtherWallet有接收主币的能力
    // receive() external payable { 
    //     emit Log(address(this), msg.value, "call from receive");
    // }

    // //可以通过调用这个方法来充值，msg.value会自动添加到这个合约的余额中
    // function deposit() external payable {
    // }
}
