// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/UniswapV2Router02.sol";
import "../src/UniswapV2Pair.sol";
import "../src/UniswapV2Factory.sol";
import "./utils/ERC20.sol";
import {console} from "./utils/Console.sol";
import {stdStorage, Test} from "forge-std/Test.sol";
import {Utils} from "./utils/Utils.sol";

contract BaseSetup is Test {
    Utils internal utils;
    address payable[] internal users;
    ERC20[] internal tokens;
    address internal alice;
    address internal bob;
    // make sure address token0 < token1
    address internal token0;
    address internal token1;

    function setUp() public virtual {
        utils = new Utils();
        users = utils.createUsers(5);

        alice = users[0];
        vm.label(alice, "Alice");
        bob = users[1];
        vm.label(bob, "Bob");

        tokens = utils.createTokens(5);
        (token0, token1) = address(tokens[0]) < address(tokens[1])
        ? (address(tokens[0]), address(tokens[1]))
        : (address(tokens[1]), address(tokens[0]));
    }
}
