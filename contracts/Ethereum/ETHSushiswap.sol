// SPDX-License-Identifier: MIT;

pragma solidity >= 0.6.6;

import '@uniswap/v2-periphery/contracts/interfaces/IERC20.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';
import '@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol';
import './IMasterChef.sol';

// EVENTS 

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

    IUniswapV2Router02 sushiRouter02;
    IMasterChef masterChef;
    

    receive() external payable {

    }
    
    constructor(IUniswapV2Router02 _sushiRouter02, address _factory,IMasterChef _masterChef) public {
        sushiRouter02 = _sushiRouter02;
        masterChef = _masterChef;
    }


       /////////////////////////////// SUSHISWAP ///////////////////////////////////////

 function exchangeTokenToToken(address _tokenA, address _tokenB, uint256 _amountAIn) external {

        require(IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountAIn), 'transferFrom failed.');
        require(IERC20(_tokenA).approve(address(sushiRouter02), _amountAIn), 'approve failed.');

        address[] memory path = new address[](2);
        path[0] = _tokenA;
        path[1] = _tokenB;

        uint[] memory amounts = sushiRouter02.swapExactTokensForTokens(_amountAIn, 0, path, msg.sender, block.timestamp);

        emit ExchangeTokenToToken(amounts);
    }  

 function exchangeTokenToEth(address _tokenA, uint256 _amountAIn) external {

        require(IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountAIn), 'transferFrom failed.');
        require(IERC20(_tokenA).approve(address(sushiRouter02), _amountAIn), 'approve failed.');

        address[] memory path = new address[](2);
        path[0] = _tokenA;
        path[1] = sushiRouter02.WETH();

        uint[] memory amounts = sushiRouter02.swapExactTokensForETH(_amountAIn, 0, path, msg.sender, block.timestamp);

        emit ExchangeTokenToEth(amounts);
    }

 function exchangeEthToToken(address _tokenB) external payable {

        (bool successFund,) = address(sushiRouter02).call{value : msg.value}("");
        require(successFund, "failed to fund BNB to the pancake router");

        address[] memory path = new address[](2);
        path[0] = sushiRouter02.WETH();
        path[1] = _tokenB;

        uint[] memory amounts = sushiRouter02.swapExactETHForTokens(0, path, msg.sender, block.timestamp);

        emit ExchangeEthToToken(amounts);
    }

 function addLiquidity(address _tokenA, address _tokenB, uint _amountADesired, uint _amountBDesired) external {

        require(IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountADesired), 'transferFrom failed.');
        require(IERC20(_tokenA).approve(address(sushiRouter02), _amountADesired), 'approve failed.');
        
        require(IERC20(_tokenB).transferFrom(msg.sender, address(this), _amountBDesired), 'transferFrom failed.');
        require(IERC20(_tokenB).approve(address(sushiRouter02), _amountBDesired), 'approve failed.');

        (uint amountA, uint amountB, uint liquidity) = sushiRouter02.addLiquidity(_tokenA, _tokenB, _amountADesired, _amountBDesired, 0, 0, msg.sender, block.timestamp);

        emit AddLiquidity(amountA, amountB, liquidity);
    }

 function addLiquidityETH(address _token, uint _amountDesired) external payable {

        require(IERC20(_token).transferFrom(msg.sender, address(this), _amountDesired), 'transferFrom failed.');
        require(IERC20(_token).approve(address(sushiRouter02), _amountDesired), 'approve failed.');

        (bool successFund,) = address(sushiRouter02).call{value : msg.value}("");
        require(successFund, "failed to fund BNB to the pancake router");

        (uint amountToken, uint amountETH, uint liquidity) = sushiRouter02.addLiquidityETH(_token, _amountDesired, 0, 0, msg.sender, block.timestamp);

        emit AddLiquidityETH(amountToken, amountETH, liquidity);
    }

 function removeLiquidity(address _tokenA, address _tokenB, address _pair, uint _liquidity) external {

        require(IERC20(_pair).transferFrom(msg.sender, _pair, _liquidity), 'transferFrom failed.');
        require(IERC20(_pair).approve(address(sushiRouter02), _liquidity), 'approve failed.');
        
        (uint amountA, uint amountB) = sushiRouter02.removeLiquidity(_tokenA, _tokenB, _liquidity, 0, 0, msg.sender, block.timestamp);

        emit RemoveLiquidity(amountA, amountB);
    }

 function removeLiquidityETH(address _token, address _pair, uint _amountDesired) external {

        require(IERC20(_pair).transferFrom(msg.sender, _pair, _amountDesired), 'transferFrom failed.');
        require(IERC20(_pair).approve(address(sushiRouter02), _amountDesired), 'approve failed.');
        
        (uint amountToken, uint amountETH) = sushiRouter02.removeLiquidityETH(_token, _amountDesired, 0, 0, msg.sender, block.timestamp);

        emit RemoveLiquidityETH(amountToken, amountETH);
    }

  function depositFarm(uint256 _pid, uint256 _amount) external {
        //ToDo - Check Deposit Fee
        masterChef.deposit(_pid, _amount);
     }

  function withdrawFarm(uint256 _pid, uint256 _amount) external {
        //ToDo - Check Withdraw Fee
        masterChef.withdraw(_pid, _amount);
     }

  function emergencyWithdrawFarm(uint256 _pid) external {
        //ToDo - Check Emergency Withdraw Fee
        masterChef.emergencyWithdraw(_pid);
     }

  function harvestFarm(uint256 _pid) external {
        //ToDo - Check Deposit Fee
        masterChef.deposit(_pid, 0);
     }


} 