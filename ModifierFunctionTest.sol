// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

contract ModifierFunctionTest {
    bool private paused; //默认是false
    //public 状态变量会默认生成同名的函数，供外界访问，此时为：function count() external returns(uint) { return count;}
    uint public count;

    function setPaused(bool _paused) external {
        paused = _paused;
    }

    function inc() external whenNotPaused {
        count += 1;
    }

    function dec() external whenNotPaused {
        count -= 1;
    }

    function incBy(uint _x) external whenNotPaused cap(_x) {
        count += _x;
    }

    function decBy(uint _x) external whenNotPaused cap(_x) {
        count -= _x;
    }

    modifier whenNotPaused() {
        require(!paused, "paused");
        //表示校验通过，函数继续执行
        _;
    }

    modifier cap(uint _x) {
        require(_x < 100, "_x>=100");
        _;
    }
}
