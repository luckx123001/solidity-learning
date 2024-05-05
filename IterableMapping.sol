// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

//通过数组+mapping来实现可遍历的mapping
contract IterableMapping {

    //地址 => 余额
    mapping(address => uint) public balances;

    //是否已经插入
    mapping(address => bool) public inserted;

    address[] public keys;

    function set(address _address, uint _val) external {
        balances[_address] = _val;

        if (!inserted[_address]) {
            inserted[_address] = true;
            keys.push(_address);
        }
    }

    function getSize() external view returns(uint) {
        return keys.length;
    }

    function first() external view returns(uint) {
        return balances[keys[0]];
    }

    function last() external view returns(uint) {
        return balances[keys[keys.length - 1]];
    }

    function get(uint _index) external view returns(uint) {
        return balances[keys[_index]];
    }

}
