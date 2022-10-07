// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/UniswapV2Router02.sol";
import "../src/UniswapV2Pair.sol";
import "../src/UniswapV2Factory.sol";
import "./utils/WETH10.sol";
import "./BaseSetup.t.sol";

contract RouterTest is BaseSetup {
    UniswapV2Factory public factory = new UniswapV2Factory(alice);
    WETH10 weth = new WETH10();
    UniswapV2Router02 public router;

    function setUp() public virtual override {
        BaseSetup.setUp();
        // replace the below bytecode inside the UniswapV2Library.pairFor()
        // string memory pairByteCode = utils.getPairByteCode();
        tokens[0].mint(alice, 10e20);
        tokens[1].mint(alice, 10e20);
        tokens[2].mint(alice, 10e20);
        router = new UniswapV2Router02(address(factory), address(weth));
    }

    //
    function mockAddLiquidity(address tokenA, address tokenB, uint256 amountADesired,
    uint256 amountBDesired, uint256 amountAMin, uint256 amountBMin) public {
        vm.startPrank(alice);
        IUniswapV2ERC20(tokenA).approve(address(router),type(uint256).max);
        IUniswapV2ERC20(tokenB).approve(address(router),type(uint256).max);
        router.addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin, alice, block.timestamp+200);
        vm.stopPrank();
    }


    function testAddLiquidity() public {
        address token2 = address(tokens[2]);
        mockAddLiquidity(token0, token2, 2e3, 2e3, 1e3, 1e3);
        address pair = UniswapV2Library.pairFor(address(factory), token0, token2);
        assertEq(UniswapV2ERC20(pair).balanceOf(alice), 1000);
    }

    function testSequentAddLiquidity() public {
        mockAddLiquidity(token0, token1, 2e3, 2e3, 0, 0);
        uint256 balance0before = ERC20(token0).balanceOf(alice);
        uint256 balance1before = ERC20(token1).balanceOf(alice);
        mockAddLiquidity(token1, token0, 1e3, 2e3, 0, 0);
        address pair = UniswapV2Library.pairFor(address(factory), token0, token1);
        assertEq(UniswapV2ERC20(pair).balanceOf(alice), 2000);
        assertEq(balance0before-1e3, IERC20(token0).balanceOf(alice));
        assertEq(balance0before-1e3, IERC20(token1).balanceOf(alice));
    }

    function testAddLiquidityETH() public {
        vm.startPrank(alice);
        IUniswapV2ERC20(token0).approve(address(router),type(uint256).max);
        (bool success, bytes memory result) = address(router).call{value: 2e-15 ether}(
            abi.encodeWithSignature(
        "addLiquidityETH(address,uint256,uint256,uint256,address,uint256)", token0, 2e3, 0, 0, alice, block.timestamp+200)
        );
        vm.stopPrank();
        assertEq(success, true);
        (uint256 amountToken, uint256 amountETH, uint256 liquidity) = abi.decode(result, (uint256, uint256, uint256));
        assertEq(amountToken, 2e3);
        assertEq(amountETH, 2e3);
        assertEq(liquidity, 1e3);
    }

    function testRemoveLiquidity() public {
        mockAddLiquidity(token0, token1, 2e3, 2e3, 0, 0);
        address pair = UniswapV2Library.pairFor(address(factory), token0, token1);
        uint256 balance0before = ERC20(token0).balanceOf(alice);
        uint256 balance1before = ERC20(token1).balanceOf(alice);
        vm.startPrank(alice);
        IUniswapV2ERC20(pair).approve(address(router),type(uint256).max);
        router.removeLiquidity(token0, token1, 100, 0, 0 , alice, block.timestamp+200);
        assertEq(UniswapV2ERC20(pair).balanceOf(alice), 900);
        assertEq(balance0before+100, IERC20(token0).balanceOf(alice));
        assertEq(balance0before+100, IERC20(token1).balanceOf(alice));
    }

    function testRemoveLiquidityETH() public {
        vm.startPrank(alice);
        IUniswapV2ERC20(token0).approve(address(router),type(uint256).max);
        (bool success, bytes memory result) = address(router).call{value: 2e-15 ether}(
            abi.encodeWithSignature(
                "addLiquidityETH(address,uint256,uint256,uint256,address,uint256)", token0, 2e3, 0, 0, alice, block.timestamp+20)
        );
        address pair = UniswapV2Library.pairFor(address(factory), token0, address(weth));
        uint256 balance0before = ERC20(token0).balanceOf(alice);
        uint256 balancebefore = alice.balance;
        console.log(balancebefore);
        IUniswapV2ERC20(pair).approve(address(router),type(uint256).max);
        router.removeLiquidityETH(token0, 100, 0, 0 , alice, block.timestamp+20);
        assertEq(UniswapV2ERC20(pair).balanceOf(alice), 900);
        assertEq(balance0before+100, IERC20(token0).balanceOf(alice));
        assertEq(balancebefore+100, alice.balance);
    }

}