// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {Test} from "forge-std/Test.sol";
import "./ERC20.sol";
import "../../src/UniswapV2Pair.sol";

contract Utils is Test {
    bytes32 internal nextUser = keccak256(abi.encodePacked("user address"));

    function getNextUserAddress() external returns (address payable) {
        address payable user = payable(address(uint160(uint256(nextUser))));
        nextUser = keccak256(abi.encodePacked(nextUser));
        return user;
    }

    // create users with 100 ETH balance each
    function createUsers(uint256 userNum)
    external
    returns (address payable[] memory)
    {
        address payable[] memory users = new address payable[](userNum);
        for (uint256 i = 0; i < userNum; i++) {
            address payable user = this.getNextUserAddress();
            vm.deal(user, 100 ether);
            users[i] = user;
        }

        return users;
    }

    function createTokens(uint256 tokenNum)
    external
    returns (ERC20[] memory)
    {
        ERC20[] memory tokens = new ERC20[](tokenNum);
        for (uint256 i = 0; i < tokenNum; i++) {
            //string memory name = string.concat("token", uintToString(i));
            // address token = new ERC20("token", i);
            tokens[i] = new ERC20("token", "TK");
        }
        return tokens;
    }


    // move block.number forward by a given number of blocks
    function mineBlocks(uint256 numBlocks) external {
        uint256 targetBlock = block.number + numBlocks;
        vm.roll(targetBlock);
    }

    function getPairByteCode() public pure returns (string memory) {
        bytes memory bytecode = type(UniswapV2Pair).creationCode;

        string memory newCreationCodeHex = uint2hexstr(
            uint256(keccak256(bytecode))
        );
        return newCreationCodeHex;

    }

    function uint2hexstr(uint256 i) public pure returns (string memory) {
        if (i == 0) return "0";
        uint256 j = i;
        uint256 length;
        while (j != 0) {
        length++;
        j = j >> 4;
        }
        uint256 mask = 15;
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        while (i != 0) {
        uint256 curr = (i & mask);
        bstr[--k] = curr > 9
        ? bytes1(uint8(55 + curr))
        : bytes1(uint8(48 + curr)); // 55 = 65 - 10
        i = i >> 4;
        }
        return string(bstr);
    }

}