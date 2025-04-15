// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Test } from "forge-std/Test.sol";
import { StdInvariant } from "forge-std/StdInvariant.sol";
import { ERC20Mock } from "../mocks/ERC20Mock.sol";
import { PoolFactory } from "src/PoolFactory.sol";
import { TSwapPool } from "src/TSwapPool.sol";

contract Invariant is StdInvariant, Test {
    // this represents the other token on the pool that is not WETH
    ERC20Mock poolToken;
    ERC20Mock weth;

    int256 constant STARTING_X = 100e18; // starting amount of "POOLT"
    int256 constant STARTING_Y = 50e18; // starting amount of "WETH"

    // this will be the pool factory that will be used to create pools
    PoolFactory poolFactory;
    // this will be the pool created by the factory (poolToken/weth)
    TSwapPool pool;

    function setUp() public {
        // create the 2 tokens for the pool
        poolToken = new ERC20Mock("Pool Token", "POOLT");
        weth = new ERC20Mock("Wrapped Ether", "WETH");

        // set up the pool factory and his resulting pool
        poolFactory = new PoolFactory(address(weth));
        pool = TSwapPool(poolFactory.createPool(address(poolToken)));

        // mint those tokens for the pool
        poolToken.mint(address(this), uint256(STARTING_X));
        weth.mint(address(this), uint256(STARTING_Y));

        // approve the pool to spend the tokens
        poolToken.approve(address(pool), type(uint256).max);
        weth.approve(address(weth), type(uint256).max);

        // set the deposit into the pool
        pool.deposit(uint256(STARTING_Y), uint256(STARTING_Y), uint256(STARTING_X), uint64(block.timestamp));
    }

    function statefulFuzz_constantProductFormulaStaysTheSame() public { }
}
