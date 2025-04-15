// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Test, console2 } from "forge-std/Test.sol";
import { TSwapPool } from "src/TSwapPool.sol";
import { ERC20Mock } from "../mocks/ERC20Mock.sol";

contract Handler is Test {
    TSwapPool pool;

    ERC20Mock weth;
    ERC20Mock poolToken;

    int256 startingX;
    int256 startingY;
    int256 endingX;
    int256 endingY;
    int256 expectedDeltaX;
    int256 expectedDeltaY;
    int256 actualDeltaX;
    int256 actualDeltaY;

    address liquidityProvider = makeAddr("lp");
    address swapper = makeAddr("swapper");

    constructor(TSwapPool _pool, ERC20Mock _weth, ERC20Mock _poolToken) {
        pool = _pool;
        weth = _weth;
        poolToken = _poolToken;
    }

    function swapPoolTokenForWethBasedOnOutputWeth(uint256 outputWeth) public {
        outputWeth = bound(outputWeth, 0, type(uint64).max); //18446744073709551615
        if (outputWeth >= weth.balanceOf(address(pool))) {
            return;
        }
        uint256 poolTokenAmount = pool.getInputAmountBasedOnOutput(
            outputWeth, poolToken.balanceOf(address(pool)), weth.balanceOf(address(pool))
        );
        if (poolTokenAmount >= type(uint64).max) {
            return;
        }

        // update starting values
        startingY = int256(weth.balanceOf(address(this)));
        startingX = int256(poolToken.balanceOf(address(this)));
        // update expected values
        expectedDeltaY = int256(-1) * int256(outputWeth);
        expectedDeltaX = int256(pool.getPoolTokensToDepositBasedOnWeth(poolTokenAmount));
    }

    function deposit(uint256 _wethAmount) public {
        _wethAmount = bound(_wethAmount, 0, type(uint64).max); //18446744073709551615

        // Starting values
        startingY = int256(weth.balanceOf(address(this)));
        startingX = int256(poolToken.balanceOf(address(this)));
        // expected values
        expectedDeltaY = int256(_wethAmount);
        expectedDeltaX = int256(pool.getPoolTokensToDepositBasedOnWeth(_wethAmount));

        vm.startPrank(liquidityProvider);
        weth.mint(address(pool), _wethAmount);
        poolToken.mint(address(pool), uint256(expectedDeltaX));

        weth.approve(address(pool), type(uint256).max);
        poolToken.approve(address(pool), type(uint256).max);

        pool.deposit(_wethAmount, 0, uint256(expectedDeltaX), uint64(block.timestamp));

        endingX = int256(poolToken.balanceOf(address(this)));
        endingY = int256(weth.balanceOf(address(this)));

        actualDeltaX = int256(endingX) - int256(startingX);
        actualDeltaY = int256(endingY) - int256(startingY);
    }
}

// (3+2) * (7-dy) =20
// 7-dy = 20 / 5
// -dy = 4 - 7
// dy = 3
