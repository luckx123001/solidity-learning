// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;
// msg.data不为空时,会触发调用fallback来接收主币，如果没定义，则接收主币失败
// msg.data为空时，会触发调用receive方法来接收主币，如果没定义，则会调用fallback方法
// 只有函数标记为payable时，才能接收主币
//问题：接收的主币存在哪里了？？？？？？
contract Payable {

    //用payable标记的变量，说明该地址可以发送以太坊主币(eth)
    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    //用payable标记的方法，说明该方法可以接收以太坊主币(eth)
    function deposit() external payable {

    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    fallback() external payable { 
        emit Log("fallback", msg.sender, msg.value, msg.data);
    }

    receive() external payable { 
        emit Log("receive", msg.sender, msg.value, "");
    }

    event Log(string func, address sender, uint value, bytes data);
}
