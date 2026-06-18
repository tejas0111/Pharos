// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import {PharosERC20} from "../contracts/PharosERC20.sol";

contract PharosERC20Handler is Test {
    PharosERC20 public token;
    address public owner;

    // Known actors for fuzzing
    address[] public actors;

    constructor(PharosERC20 _token, address _owner) {
        token = _token;
        owner = _owner;
        actors.push(_owner);
        actors.push(address(0x1000));
        actors.push(address(0x2000));
        actors.push(address(0x3000));
        actors.push(address(0x4000));
    }

    function transfer(uint256 actorIndex, uint256 rawAmount) public {
        address from = actors[actorIndex % actors.length];
        address to = actors[(actorIndex + 1) % actors.length];
        uint256 bal = token.balanceOf(from);
        if (from == to || to == address(0) || bal == 0) return;
        uint256 amount = rawAmount % bal;
        vm.prank(from);
        token.transfer(to, amount == 0 ? 1 : amount);
    }

    function approve(uint256 actorIndex, uint256 spenderIndex, uint256 amount) public {
        address caller = actors[actorIndex % actors.length];
        address spender = actors[spenderIndex % actors.length];
        if (spender == address(0)) return;
        vm.prank(caller);
        token.approve(spender, amount);
    }

    function transferFrom(uint256 callerIndex, uint256 fromIndex, uint256 toIndex, uint256 rawAmount) public {
        address caller = actors[callerIndex % actors.length];
        address from = actors[fromIndex % actors.length];
        address to = actors[toIndex % actors.length];
        if (from == to || to == address(0)) return;
        uint256 allowance = token.allowance(from, caller);
        if (allowance == 0) return;
        uint256 amount = rawAmount % allowance;
        vm.prank(caller);
        token.transferFrom(from, to, amount == 0 ? 1 : amount);
    }

    function mint(uint256 rawAmount) public {
        uint256 remaining = token.MAX_SUPPLY() - token.totalSupply();
        if (remaining == 0) return;
        uint256 amount = rawAmount % remaining;
        if (amount == 0) amount = 1;
        address to = actors[rawAmount % actors.length];
        if (to == address(0)) to = actors[1];
        vm.prank(owner);
        token.mint(to, amount);
    }
}
