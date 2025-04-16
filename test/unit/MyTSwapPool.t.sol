// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Test, console } from "forge-std/Test.sol";
import { TSwapPool } from "../../src/PoolFactory.sol";
import { ERC20Mock } from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";

contract MyTSwapPoolTest is Test {
    TSwapPool pool;
    ERC20Mock poolToken;
    ERC20Mock weth;

    uint256 constant WETH_AMOUNT = 5e18;
    uint256 constant POOL_TOKEN_AMOUNT = 2e18;
    // correspond to 97%
    uint256 constant FEE_NUMERATOR = 1000;
    uint256 constant FEE_DENOMINATOR = 997;

    function setUp() public {
        poolToken = new ERC20Mock();
        weth = new ERC20Mock();
        pool = new TSwapPool(address(poolToken), address(weth), "Liquidity Token", "LITO");

        weth.mint(address(pool), WETH_AMOUNT);
        poolToken.mint(address(pool), POOL_TOKEN_AMOUNT);
    }

    function test_InputAmountBasedOnOutputRespectsFee() public view {
        uint256 wethBalance = weth.balanceOf(address(pool));
        uint256 poolTokenBalance = poolToken.balanceOf(address(pool));

        uint256 outputWeth = 1e18;

        uint256 expectedPoolTokenAmount =
            (outputWeth * poolTokenBalance * FEE_NUMERATOR) / ((wethBalance - outputWeth) * FEE_DENOMINATOR);

        uint256 actualPoolTokenAmount = pool.getInputAmountBasedOnOutput(outputWeth, poolTokenBalance, wethBalance);

        assertEq(expectedPoolTokenAmount, actualPoolTokenAmount);
    }
}

// xy = (x - dx) * (y + dy)
// xy = xy + xdy - dxy - dxdy
// xdy - dxdy = - dxy
// dy * (x - dx) = - dxy
// dy = (dx * y) / (x - dx)
