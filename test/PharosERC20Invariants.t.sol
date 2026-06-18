// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "forge-std/StdInvariant.sol";
import {PharosERC20} from "../contracts/PharosERC20.sol";
import {PharosERC20Handler} from "./PharosERC20Handler.sol";

contract PharosERC20Invariants is StdInvariant, Test {
    PharosERC20 private s_token;
    PharosERC20Handler private s_handler;

    function setUp() public {
        address owner = address(0x1234);
        vm.startPrank(owner);
        s_token = new PharosERC20("InvariantToken", "INV", 1_000_000 ether);
        vm.stopPrank();
        s_handler = new PharosERC20Handler(s_token, owner);
        targetContract(address(s_handler));
    }

    function invariant_total_supply_never_exceeds_max() public view {
        assertLe(s_token.totalSupply(), s_token.MAX_SUPPLY());
    }

    function invariant_owner_balance_non_negative() public view {
        assertGe(s_token.balanceOf(address(0x1234)), 0);
    }

    function invariant_max_supply_constant() public view {
        assertEq(s_token.MAX_SUPPLY(), 1_000_000_000e18);
    }
}
