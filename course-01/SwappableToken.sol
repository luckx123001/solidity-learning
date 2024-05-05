// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@5.0.2/token/ERC20/ERC20.sol";


contract SwappableToken is ERC20 {

    constructor(string memory _name, string memory _symbol,uint _amount)
        ERC20(_name, _symbol)
    {
        _mint(msg.sender, _amount * 10 ** decimals());
    }

    function approve(address owner, address spender, uint amount) public returns(bool) {
        _approve(owner, spender, amount);
        return true;
    }
}
