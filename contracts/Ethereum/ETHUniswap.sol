// SPDX-License-Identifier: MIT;

pragma solidity >= 0.6.6;

import '@uniswap/v2-periphery/contracts/interfaces/IERC20.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';
import '@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol';

contract ETHUniswap {

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

    IUniswapV2Router02 uniswapRouter02;
    

    receive() external payable {

    }
    
    constructor(IUniswapV2Router02 _uniswapRouter02, address _factory) public {
        uniswapRouter02 = _uniswapRouter02;
    }


       /////////////////////////////// UNISWAP ///////////////////////////////////////

 function swapTokenToToken(address _tokenA, address _tokenB, uint256 _amountAIn) external {

        require(IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountAIn), 'transferFrom failed.');
        require(IERC20(_tokenA).approve(address(uniswapRouter02), _amountAIn), 'approve failed.');

        address[] memory path = new address[](2);
        path[0] = _tokenA;
        path[1] = _tokenB;

        uint[] memory amounts = uniswapRouter02.swapExactTokensForTokens(_amountAIn, 0, path, msg.sender, block.timestamp);

        emit ExchangeTokenToToken(amounts);
    }  

 function exchangeTokenToEth(address _tokenA, uint256 _amountAIn) external {

        require(IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountAIn), 'transferFrom failed.');
        require(IERC20(_tokenA).approve(address(uniswapRouter02), _amountAIn), 'approve failed.');

        address[] memory path = new address[](2);
        path[0] = _tokenA;
        path[1] = uniswapRouter02.WETH();

        uint[] memory amounts = uniswapRouter02.swapExactTokensForETH(_amountAIn, 0, path, msg.sender, block.timestamp);

        emit ExchangeTokenToEth(amounts);
    }

 function exchangeEthToToken(address _tokenB) external payable {

        (bool successFund,) = address(uniswapRouter02).call{value : msg.value}("");
        require(successFund, "failed to fund BNB to the pancake router");

        address[] memory path = new address[](2);
        path[0] = uniswapRouter02.WETH();
        path[1] = _tokenB;

        uint[] memory amounts = uniswapRouter02.swapExactETHForTokens(0, path, msg.sender, block.timestamp);

        emit ExchangeEthToToken(amounts);
    }

 function addLiquidity(address _tokenA, address _tokenB, uint _amountADesired, uint _amountBDesired) external {

        require(IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountADesired), 'transferFrom failed.');
        require(IERC20(_tokenA).approve(address(uniswapRouter02), _amountADesired), 'approve failed.');
        
        require(IERC20(_tokenB).transferFrom(msg.sender, address(this), _amountBDesired), 'transferFrom failed.');
        require(IERC20(_tokenB).approve(address(uniswapRouter02), _amountBDesired), 'approve failed.');

        (uint amountA, uint amountB, uint liquidity) = uniswapRouter02.addLiquidity(_tokenA, _tokenB, _amountADesired, _amountBDesired, 0, 0, msg.sender, block.timestamp);

        emit AddLiquidity(amountA, amountB, liquidity);
    }

 function addLiquidityETH(address _token, uint _amountDesired) external payable {

        require(IERC20(_token).transferFrom(msg.sender, address(this), _amountDesired), 'transferFrom failed.');
        require(IERC20(_token).approve(address(uniswapRouter02), _amountDesired), 'approve failed.');

        (bool successFund,) = address(uniswapRouter02).call{value : msg.value}("");
        require(successFund, "failed to fund BNB to the pancake router");

        (uint amountToken, uint amountETH, uint liquidity) = uniswapRouter02.addLiquidityETH(_token, _amountDesired, 0, 0, msg.sender, block.timestamp);

        emit AddLiquidityETH(amountToken, amountETH, liquidity);
    }

 function removeLiquidity(address _tokenA, address _tokenB, address _pair, uint _liquidity) external {

        require(IERC20(_pair).transferFrom(msg.sender, _pair, _liquidity), 'transferFrom failed.');
        require(IERC20(_pair).approve(address(uniswapRouter02), _liquidity), 'approve failed.');
        
        (uint amountA, uint amountB) = uniswapRouter02.removeLiquidity(_tokenA, _tokenB, _liquidity, 0, 0, msg.sender, block.timestamp);

        emit RemoveLiquidity(amountA, amountB);
    }

 function removeLiquidityETH(address _token, address _pair, uint _amountDesired) external {

        require(IERC20(_pair).transferFrom(msg.sender, _pair, _amountDesired), 'transferFrom failed.');
        require(IERC20(_pair).approve(address(uniswapRouter02), _amountDesired), 'approve failed.');
        
        (uint amountToken, uint amountETH) = uniswapRouter02.removeLiquidityETH(_token, _amountDesired, 0, 0, msg.sender, block.timestamp);

        emit RemoveLiquidityETH(amountToken, amountETH);
    }


}     




