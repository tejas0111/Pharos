// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {StakingPool} from "../contracts/StakingPool.sol";

/// @title Deploy StakingPool
/// @notice Deploy script with chain-ID validation for Pharos safety
contract DeployStakingPool is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        address stakingToken = vm.envAddress("STAKING_TOKEN");
        address rewardToken = vm.envAddress("REWARD_TOKEN");
        uint256 rewardRate = vm.envOr("REWARD_RATE", uint256(1 ether));
        uint256 rewardDuration = vm.envOr("REWARD_DURATION", uint256(30 days));

        console.log("Deploying StakingPool...");
        console.log("Deployer:", deployer);
        console.log("Chain ID:", block.chainid);
        console.log("Staking Token:", stakingToken);
        console.log("Reward Token:", rewardToken);

        vm.startBroadcast(deployerPrivateKey);
        StakingPool pool = new StakingPool(
            stakingToken,
            rewardToken,
            rewardRate,
            rewardDuration,
            block.chainid
        );
        vm.stopBroadcast();

        console.log("StakingPool deployed at:", address(pool));

        if (block.chainid == 688689) {
            console.log(string.concat("View: https://atlantic.pharosscan.xyz/address/", vm.toString(address(pool))));
        } else if (block.chainid == 1672) {
            console.log(string.concat("View: https://www.pharosscan.xyz/address/", vm.toString(address(pool))));
        }
    }
}
