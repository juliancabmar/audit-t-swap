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

    // this will be the pool factory that will be used to create pools
    PoolFactory poolFactory;
    // this will be the pool created by the factory (poolToken/weth)
    TSwapPool pool;

    function setUp() public {
        poolToken = new ERC20Mock("Pool Token", "POOLT");
        weth = new ERC20Mock("Wrapped Ether", "WETH");
        poolFactory = new PoolFactory(address(weth));
        pool = TSwapPool(poolFactory.createPool(address(poolToken)));
    }
}
