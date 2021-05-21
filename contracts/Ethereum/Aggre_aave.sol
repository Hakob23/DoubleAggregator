// SPDX-License-Identifier: MIT

pragma solidity >0.6.6;

import "./interface/IAERC20.sol";
import "./interface/IAETH.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Aggregator {

    event ExchangeTokenToToken(
        uint[] amounts
    );

    event ExchangeTokenToEth(
        uint[] amounts
    );

    event ExchangeEthToToken(
        uint[] amounts
    );

    event AddLiquidity(
        uint amountA,
        uint amountB, 
        uint liquidity
    );

    event AddLiquidityETH(
        uint amountToken,
        uint amountETH, 
        uint liquidity
    );

    event RemoveLiquidity(
        uint amountA,
        uint amountB
    );

    event RemoveLiquidityETH(
        uint amountToken,
        uint amountETH
    );

    IPancakeRouter02 pancakeRouter02;
    IMasterChef masterChef;
    address public factory;

    receive() external payable {

    }
    
    constructor(IPancakeRouter02 _pancakeRouter02, address _factory, IMasterChef _masterChef) public {
        pancakeRouter02 = _pancakeRouter02;
        factory = _factory;
        masterChef = _masterChef;
    }

     function supplyToken(address _underlying, address _aToken, uint256 amount) external {
        require(_underlying != address(0), "Aggregator.supplyToken: underlying address should not be zero address");
        require(_aToken != address(0), "Aggregator.supplyToken: atoken address should not be zero address");

        IERC20 underlying = IERC20(_underlying);
        IAERC20 aToken = IAERC20(_aToken);
        underlying.approve(address(aToken), amount);

        require(aToken.mint(amount) == 0, "Aggregator.supplyToken: Error mint atoken");
    }

    function withdrawToken(address _aToken, uint256 amount) external {
        require(_aToken != address(0), "Aggregator.withdrawToken: atoken address should not be zero address");

        IAERC20 aToken = IAERC20(_aToken);

        require(aToken.redeemUnderlying(amount) == 0, "Aggregator.withdrawToken: Error reedem token");
    }

    function supplyEth(address _aEth) external payable {
        require(_aEth != address(0), "Aggregator.supplyEth: aeth address should not be zero address");

        IAETH aEth = ICETH(_aEth);
        aEth.mint{value: msg.value}();
    }

    function withdrawEth(address _aEth, uint256 amount) external {
        require(_aEth != address(0), "Aggregator.withdrawToken: aEth address should not be zero address");

        IAETH aEth = IAETH(_aEth);

        require(aEth.redeemUnderlying(amount) == 0, "Aggregator.withdrawToken: Error reedem token");
    }

    function borrowToken(address _aToken, uint256 amount) external {
        require(_aToken != address(0), "Aggregator.borrowToken: atoken address should not be zero address");

        IAERC20 aToken = IAERC20(_aToken);

        require(aToken.borrow(amount) == 0, "Aggregator.borrowToken: Error borrow token");
    }

    function repayBorrowToken(address _underlying, address _aToken, uint256 amount) external {
        require(_underlying != address(0), "Aggregator.repayBorrowToken: underlying address should not be zero address");
        require(_aToken != address(0), "Aggregator.repayBorrowToken: atoken address should not be zero address");

        ERC20 underlying = ERC20(_underlying);
        IAERC20 aToken = IAERC20(_aToken);
        underlying.approve(address(aToken), amount);

        require(aToken.repayBorrow(amount) == 0, "Aggregator.repayBorrowToken: Error repay borrow token");
    }

    function borrowEth(address _aEth, uint256 amount) external {
        require(_aEth != address(0), "Aggregator.borrowEth: atoken address should not be zero address");

        IAETH aEth = IAETH(_aEth);

        require(aEth.borrow(amount) == 0, "Aggregator.borrowEth: Error borrow bnb");
    }

    function repayBorrowEth(address _underlying, address _aEth) external payable {
        require(_underlying != address(0), "Aggregator.repayBorrowEth: underlying address should not be zero address");
        require(_aEth != address(0), "Aggregator.repayBorrowEth: aeth address should not be zero address");

        IAETH aEth = IAETH(_aEth);
        aEth.repayBorrow{value: msg.value}();
    }

}

