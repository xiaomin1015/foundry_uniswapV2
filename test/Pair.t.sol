// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/UniswapV2Router02.sol";
import "../src/UniswapV2Pair.sol";
import "../src/UniswapV2Factory.sol";
import "./BaseSetup.t.sol";

contract PairTest is BaseSetup {
    address public pair;
    UniswapV2Factory public factory = new UniswapV2Factory(alice);

    function setUp() public virtual override {
        BaseSetup.setUp();
        tokens[0].mint(alice, 10e20);
        tokens[1].mint(alice, 10e20);
        vm.prank(address(factory));
        //pair = new UniswapV2Pair();
        pair = factory.createPair(token0, token1);
    }

    //test for mint()
    function mockMint(address tokenA, address tokenB,
    uint256 amountA, uint256 amountB, address to
    ) public returns (uint256 liquidity){
        vm.startPrank(to);
        // address getpairaddress = UniswapV2Library.pairFor(address(factory), tokenA, tokenB);
        ERC20(tokenA).transfer(pair, amountA);
        ERC20(tokenB).transfer(pair, amountB);
        vm.stopPrank();
        return UniswapV2Pair(pair).mint(to);
    }

    function testMint() public {
        assertEq(address(factory), UniswapV2Pair(pair).factory());
        assertEq(UniswapV2Pair(pair).token0(), token0);
        //alice add liquidity
        uint256 liquidity = mockMint(token0, token1, 2e3, 2e3, alice);
        assertEq(liquidity, 1000);
        assertEq(IERC20(token0).balanceOf(pair), 2e3);
        assertEq(IERC20(token1).balanceOf(pair), 2e3);
        (uint112 _reserve0, uint112 _reserve1, ) = UniswapV2Pair(pair).getReserves();
        assertEq(_reserve0, 2e3);
        assertEq(_reserve1, 2e3);
        assertEq(UniswapV2Pair(pair).balanceOf(alice), 1e3);
        //assertEq(UniswapV2Pair(pair).kLast(), 4e6);
    }

    //test for burn()
    function mockBurn(address tokenA, address tokenB,
        uint256 liquidity, address to
    ) public returns (uint256 amount0, uint256 amount1){
        vm.startPrank(to);
        UniswapV2Pair(pair).transfer(pair, liquidity);
        vm.stopPrank();
        return UniswapV2Pair(pair).burn(to);
    }

    function testBurn() public {
        //alice remove liquidity
        mockMint(token0, token1, 2e3, 2e3, alice);
        assertEq(UniswapV2Pair(pair).totalSupply(), 2000);
        assertEq(IERC20(token0).balanceOf(pair), 2e3);
        (uint256 amount0, uint256 amount1) = mockBurn(token0, token1, 300, alice);
        assertEq(UniswapV2Pair(pair).balanceOf(alice), 700);
        (uint112 _reserve0, uint112 _reserve1, ) = UniswapV2Pair(pair).getReserves();
        assertEq(amount0, 300);
        assertEq(_reserve0, 1700);
        //assertEq(UniswapV2Pair(pair).kLast(), 2890000);
    }

    function mockSwap(address tokenA, address tokenB,
        uint256 amountAIn, uint256 amountBOut, address to
    ) public {
        vm.startPrank(to);
        ERC20(tokenA).transfer(pair, amountAIn);
        vm.stopPrank();
        return UniswapV2Pair(pair).swap(0, amountBOut, to, new bytes(0));
    }

    function testSwap() public {
        //alice swap token0 for token1
        mockMint(token0, token1, 2e3, 2e3, alice);
        uint256 balance0before = ERC20(token0).balanceOf(alice);
        uint256 balance1before = ERC20(token1).balanceOf(alice);
        mockSwap(token0, token1, 2e3, 998, alice);
        (uint112 _reserve0, uint112 _reserve1, ) = UniswapV2Pair(pair).getReserves();
        assertEq(_reserve0, 4000);
        assertEq(_reserve1, 1002);
        assertEq(balance0before-2e3, IERC20(token0).balanceOf(alice));
        assertEq(balance1before+998, IERC20(token1).balanceOf(alice));
    }

    function testFailSwapForMoreTokenOut() public {
        //alice swap token0 for token1
        mockMint(token0, token1, 2e3, 2e3, alice);
        vm.expectRevert(bytes("UniswapV2: K"));
        mockSwap(token0, token1, 2e3, 1000, alice);
    }

}