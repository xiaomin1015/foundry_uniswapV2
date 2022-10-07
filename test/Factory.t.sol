// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/UniswapV2Router02.sol";
import "../src/UniswapV2Pair.sol";
import "../src/UniswapV2Factory.sol";
import "./BaseSetup.t.sol";

contract FactoryTest is BaseSetup  {
    UniswapV2Factory public factory;
    function setUp() public virtual override {
        BaseSetup.setUp();
        factory = new UniswapV2Factory(alice);
    }
    //test for SetFeeTo()
    function testSetFeeTo() public {
        vm.prank(alice);
        factory.setFeeTo(bob);
        assertEq(factory.feeTo(), bob);
    }
    function testCannotSetFeeTo() public {
        vm.expectRevert(bytes("UniswapV2: FORBIDDEN"));
        vm.prank(bob);
        factory.setFeeTo(bob);
    }
    //test for SetFeeToSetter()
    function testSetFeeToSetter() public {
        vm.prank(alice);
        factory.setFeeToSetter(bob);
        assertEq(factory.feeToSetter(), bob);
    }
    function testCannotSetFeeToSetter() public {
        vm.expectRevert(bytes("UniswapV2: FORBIDDEN"));
        vm.prank(bob);
        factory.setFeeToSetter(bob);
    }

    //test for createPair()
    function mockCreatePair(address token0, address token1) public returns (address pair){
        vm.prank(alice);
        return factory.createPair(token0, token1);
    }

    function testCreatePair() public {
        assertEq(factory.allPairsLength(), 0);
        // check the event
        // vm.expectEmit(false, false, false, true);
        address pair = mockCreatePair(token0, token1);
        assertEq(pair, factory.getPair(token0,token1));
        assertEq(factory.allPairsLength(), 1);
        assertEq(IUniswapV2Pair(pair).token0(), token0);
        assertEq(IUniswapV2Pair(pair).token1(), token1);
        assertEq(IUniswapV2Pair(pair).factory(), address(factory));
    }

    function testCannotCreatePairTwice() public {
        address pair = mockCreatePair(token0, token1);
        vm.expectRevert(bytes("UniswapV2: PAIR_EXISTS"));
        mockCreatePair(token1, token0);
    }

    function testCannotCreatePairWithAddress0() public {
        vm.expectRevert(bytes("UniswapV2: ZERO_ADDRESS"));
        mockCreatePair(token1, address(0));
    }

    function testCannotCreatePairWithSameToken() public {
        vm.expectRevert(bytes("UniswapV2: IDENTICAL_ADDRESSES"));
        mockCreatePair(token1, token1);
    }
}