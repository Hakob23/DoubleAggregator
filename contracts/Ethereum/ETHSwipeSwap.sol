// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IERC20.sol";
import "hardhat/console.sol";
// import "https://github.com/SwipeWallet/Swipe-Network/blob/master/contracts/staking/StakingV3.sol";

//import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

contract SwipeController {

    event SwapTokenToToken(
        uint[] amounts
    );

    event SwapTokenToEth(
        uint[] amounts
    );

    event SwapEthToToken(
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

    event StakeSXP();

    event WithdrawSXP();

    IUniswapV2Router02 private swipeSwapRouter;
    string priceSXP = "0x8ce9137d39326ad0cd6491fb5cc0cba0e089b6a9";


    receive() external payable {

    }
    
    constructor(IUniswapV2Router02 _swipeSwapRouter02) {
        swipeSwapRouter = _swipeSwapRouter02;
    }

    function swapTokenToToken(address _tokenA, address _tokenB, uint256 _amountAIn) external {
                console.log('check');

        require(IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountAIn), "transferFrom failed.");
        require(IERC20(_tokenA).approve(address(swipeSwapRouter), _amountAIn), "approve failed.");

        address[] memory path = new address[](2);
        path[0] = _tokenA;
        path[1] = _tokenB;

        uint[] memory amounts = swipeSwapRouter.swapExactTokensForTokens(_amountAIn, 0, path, msg.sender, block.timestamp);


        emit SwapTokenToToken(amounts);
    }

    function swapTokenToEth(address _tokenA, uint256 _amountAIn) external {

        require(IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountAIn), "transferFrom failed.");
        require(IERC20(_tokenA).approve(address(swipeSwapRouter), _amountAIn), "approve failed.");

        console.log('test');

        address[] memory path = new address[](2);
        path[0] = _tokenA;
        path[1] = swipeSwapRouter.WETH();

        uint[] memory amounts = swipeSwapRouter.swapExactTokensForETH(_amountAIn, 0, path, msg.sender, block.timestamp);

        emit SwapTokenToEth(amounts);
    }

    function swapEthToToken(address _tokenB) external payable {

        (bool successFund,) = address(swipeSwapRouter).call{value : msg.value}("");
        require(successFund, "failed to fund BNB to the SwipeSwap router");

        address[] memory path = new address[](2);
        path[0] = swipeSwapRouter.WETH();
        path[1] = _tokenB;

        uint[] memory amounts = swipeSwapRouter.swapExactETHForTokens(0, path, msg.sender, block.timestamp);

        emit SwapEthToToken(amounts);
    }
    
    function addLiquidity(address _tokenA, address _tokenB, uint _amountADesired, uint _amountBDesired) external {

        require(IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountADesired), "transferFrom failed.");
        require(IERC20(_tokenA).approve(address(swipeSwapRouter), _amountADesired), "approve failed.");
        
        require(IERC20(_tokenB).transferFrom(msg.sender, address(this), _amountBDesired), "transferFrom failed.");
        require(IERC20(_tokenB).approve(address(swipeSwapRouter), _amountBDesired), "approve failed.");

        (uint amountA, uint amountB, uint liquidity) = swipeSwapRouter.addLiquidity(_tokenA, _tokenB, _amountADesired, _amountBDesired, 0, 0, msg.sender, block.timestamp);

        emit AddLiquidity(amountA, amountB, liquidity);
    }
   
   
   function addLiquidityETH(address _token, uint _amountDesired) external payable {

        require(IERC20(_token).transferFrom(msg.sender, address(this), _amountDesired), 'transferFrom failed.');
        require(IERC20(_token).approve(address(swipeSwapRouter), _amountDesired), 'approve failed.');

        (bool successFund,) = address(swipeSwapRouter).call{value : msg.value}("");
        require(successFund, "failed to fund BNB to the SwipeSwap Router");

        (uint amountToken, uint amountETH, uint liquidity) = swipeSwapRouter.addLiquidityETH(_token, _amountDesired, 0, 0, msg.sender, block.timestamp);

        emit AddLiquidityETH(amountToken, amountETH, liquidity);
    }

    function removeLiquidity(address _tokenA, address _tokenB, address _pair, uint _liquidity) external {

        require(IERC20(_pair).transferFrom(msg.sender, _pair, _liquidity), "transferFrom failed");
        require(IERC20(_pair).approve(address(swipeSwapRouter), _liquidity), "approve failed.");
        
        (uint amountA, uint amountB) = swipeSwapRouter.removeLiquidity(_tokenA, _tokenB, _liquidity, 0, 0, msg.sender, block.timestamp);

        emit RemoveLiquidity(amountA, amountB);
    }

    function removeLiquidityETH(address _token, address _pair, uint _amountDesired) external {

        require(IERC20(_pair).transferFrom(msg.sender, _pair, _amountDesired), "transferFrom failed.");
        require(IERC20(_pair).approve(address(swipeSwapRouter), _amountDesired), "approve failed.");
        
        (uint amountToken, uint amountETH) = swipeSwapRouter.removeLiquidityETH(_token, _amountDesired, 0, 0, msg.sender, block.timestamp);

        emit RemoveLiquidityETH(amountToken, amountETH);
    }

    // function stakeSXP(uint256 _amount) external {
    //     require(IERC20(priceSXP).transferFrom(msg.sender, address(this), _amount), "transferFrom failed.");
    //     require(IERC20(priceSXP).approve(address(swipeSwapRouter), _amount), "approve failed.");
    //     StakingV3.stake(_amount);

    //     emit StakeSXP();
    // }

    // function withdrawSXP(uint256 _amount) external {
    //     require(IERC20(priceSXP).transferFrom(msg.sender, address(this), _amount), "transferFrom failed.");
    //     require(IERC20(priceSXP).approve(address(swipeSwapRouter), _amount), "approve failed.");
    //     StakingV3.withdraw(_amount);

    //     emit WithdrawSXP();
    // }
}
