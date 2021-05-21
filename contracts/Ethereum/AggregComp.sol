// SPDX-License-Identifier: MIT

pragma solidity >0.6.6;


import "./interface/ICERC20.sol";
import "./interface/ICETH.sol";
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

 function supplyToken(address _underlying, address _cToken, uint256 amount) external {
        require(_underlying != address(0), "Aggregator.supplyToken: underlying address should not be zero address");
        require(_cToken != address(0), "Aggregator.supplyToken: ctoken address should not be zero address");

        IERC20 underlying = IERC20(_underlying);
        ICERC20 cToken = ICERC20(_cToken);
        underlying.approve(address(cToken), amount);

        require(cToken.mint(amount) == 0, "Aggregator.supplyToken: Error mint ctoken");
    }

    function withdrawToken(address _cToken, uint256 amount) external {
        require(_cToken != address(0), "Aggregator.withdrawToken: ctoken address should not be zero address");

        ICERC20 cToken = ICERC20(_cToken);

        require(cToken.redeemUnderlying(amount) == 0, "Aggregator.withdrawToken: Error reedem token");
    }

    function supplyEth(address _cEth) external payable {
        require(_cEth != address(0), "Aggregator.supplyEth: ceth address should not be zero address");

        ICETH cEth = ICETH(_cEth);
        cEth.mint{value: msg.value}();
    }

    function withdrawEth(address _cEth, uint256 amount) external {
        require(_cEth != address(0), "Aggregator.withdrawToken: cEth address should not be zero address");

        ICETH cEth = ICETH(_cEth);

        require(cEth.redeemUnderlying(amount) == 0, "Aggregator.withdrawToken: Error reedem token");
    }

    function borrowToken(address _cToken, uint256 amount) external {
        require(_cToken != address(0), "Aggregator.borrowToken: ctoken address should not be zero address");

        ICERC20 cToken = ICERC20(_cToken);

        require(cToken.borrow(amount) == 0, "Aggregator.borrowToken: Error borrow token");
    }

    function repayBorrowToken(address _underlying, address _cToken, uint256 amount) external {
        require(_underlying != address(0), "Aggregator.repayBorrowToken: underlying address should not be zero address");
        require(_cToken != address(0), "Aggregator.repayBorrowToken: ctoken address should not be zero address");

        ERC20 underlying = ERC20(_underlying);
        ICERC20 cToken = ICERC20(_cToken);
        underlying.approve(address(cToken), amount);

        require(cToken.repayBorrow(amount) == 0, "Aggregator.repayBorrowToken: Error repay borrow token");
    }

    function borrowEth(address _cEth, uint256 amount) external {
        require(_cEth != address(0), "Aggregator.borrowEth: ctoken address should not be zero address");

        ICETH cEth = ICETH(_cEth);

        require(cEth.borrow(amount) == 0, "Aggregator.borrowEth: Error borrow bnb");
    }

    function repayBorrowEth(address _underlying, address _cEth) external payable {
        require(_underlying != address(0), "Aggregator.repayBorrowEth: underlying address should not be zero address");
        require(_cEth != address(0), "Aggregator.repayBorrowEth: ceth address should not be zero address");

        ICETH cEth = ICETH(_cEth);
        cEth.repayBorrow{value: msg.value}();
    }

}