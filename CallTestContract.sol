// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

contract CallTestContract {

    function setX(address addr, uint _x) external {
        //这里传入的是TestContract的合约地址
        TestContract(addr).setX(_x);
    }

    function getX(address addr) external view returns(uint) {
        return TestContract(addr).getX();
    }

    //通过msg.value来传递设置的主币，所以必须标记为payable
    function setXandValue(address addr, uint _x) external payable {
        //类型(addr)来转换成该合约类型，然后再调用其方法
        TestContract(addr).setXandValue{value: msg.value}(_x);
    }

    function getXandValue(address addr) external view returns(uint x, uint value) {
        (x, value) = TestContract(addr).getXandValue();
    }

}

contract TestContract {

    uint private x;
    uint private value;

    function setX(uint _x) external {
        x = _x;
    }

    //当调用这个payable方法时，会自动给这个合约充值主币，即msg.value中的值
    //再调用getBalance()方法，就可以获取到该合约的主币(eth)余额
    function setXandValue(uint _x) external payable {
        x = _x;
        value = msg.value;
    }

    function getX() external view returns(uint) {
        return x;
    }

    function getXandValue() external view returns(uint, uint) {
        return (x, value);
    }

    function getBalance() external view returns(uint) {
        return address(this).balance;
    }
}
