// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@5.0.2/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@5.0.2/utils/math/Math.sol";
import "./SwappableToken.sol";

contract Dex {
    using Math for uint;
    address private token1;
    address private token2;
    constructor(address _token1, address _token2){
        token1 = _token1;
        token2 = _token2;
    }

    function swap(address from, address to, uint amount) public {
        require((token1 == from && token2 == to) || (token1 == to && token2 == from), "invalid token address");
        require(SwappableToken(from).balanceOf(msg.sender) >= amount, "not enough to swap");

        //计算卖出from token，卖出数量为amount, 能换回多少to token
        uint swap_amount = get_swap_price(from, to, amount);

        //先授权，再转账，这步授权应该放在外面做，就是先授权完，才来执行swap方法进行交易
        // SwappableToken(from).approve(msg.sender, address(this), amount);
        //将from token从sender转移到当前合约地址，数量为amount
        SwappableToken(from).transferFrom(msg.sender, address(this), amount);
        //将要卖出的to token, 数量为swap_amount, 授权当前Dex地址，这样DEX就有权限卖出代币to
        SwappableToken(to).approve(address(this), swap_amount);
        //DEX将代币to转给msg.sender，数量为swap_amount
        SwappableToken(to).transferFrom(address(this), msg.sender, swap_amount);
    }

    function get_swap_price(address from, address to, uint amount) public view returns(uint) {
        //SwappableToken(to).balanceOf(address(this)) ==》当前交易所地址持有的to这个合约地址代表的token
        return ((amount * SwappableToken(to).balanceOf(address(this))))/SwappableToken(from).balanceOf(address(this));
    }


    //必须先将代币授权给当前合约地址，后续才能增加流动性
    function approve(address token, uint amount) public {
        SwappableToken(token).approve(msg.sender, address(this), amount);
    }

    //添加流动性，其实本质就是往DEX合约地址转账？
    function add_liquidity(address token_address, uint amount) public {
        SwappableToken(token_address).transferFrom(msg.sender, address(this), amount);
    }
}
