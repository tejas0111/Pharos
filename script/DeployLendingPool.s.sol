// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../contracts/PharosLendingPool.sol";

contract DeployPharosLendingPool is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        uint256 maxCapacity = vm.envOr("MAX_CAPACITY", uint256(1000000e18));
        uint256 reserveFactor = vm.envOr("RESERVE_FACTOR", uint256(1000));
        uint256 collateralRatio = vm.envOr("COLLATERAL_RATIO", uint256(15000));
        uint256 maxLTV = vm.envOr("MAX_LTV", uint256(7500));
        uint256 liquidationBonus = vm.envOr("LIQUIDATION_BONUS", uint256(1000));
        uint256 baseRate = vm.envOr("BASE_RATE_PER_SEC", uint256(3170979198)); // ~10% APR
        uint256 slope1 = vm.envOr("SLOPE1_PER_SEC", uint256(6341958397)); // ~20% APR
        uint256 slope2 = vm.envOr("SLOPE2_PER_SEC", uint256(19025875191)); // ~60% APR
        uint256 optimalUtil = vm.envOr("OPTIMAL_UTILIZATION", uint256(8e17)); // 80%

        vm.startBroadcast(deployerPrivateKey);

        PharosLendingPool pool = new PharosLendingPool(
            maxCapacity, reserveFactor, collateralRatio, maxLTV, liquidationBonus,
            baseRate, slope1, slope2, optimalUtil
        );

        vm.stopBroadcast();

        console.log("Deployer:", deployer);
        console.log("PharosLendingPool deployed at:", address(pool));
        console.log("Chain ID:", block.chainid);

        if (block.chainid == 688689) {
            console.log("Explorer: https://atlantic.pharosscan.xyz/address/%s", address(pool));
        } else if (block.chainid == 1672) {
            console.log("Explorer: https://www.pharosscan.xyz/address/%s", address(pool));
        }
    }
}
