// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {SimpleLender} from "../contracts/SimpleLender.sol";

contract DeploySimpleLender is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        address collateralToken = vm.envAddress("COLLATERAL_TOKEN");
        address borrowToken = vm.envAddress("BORROW_TOKEN");
        uint256 interestRate = vm.envOr("INTEREST_RATE", uint256(317097920)); // ~1% APR

        console.log("Deploying SimpleLender...");
        console.log("Deployer:", deployer);
        console.log("Collateral:", collateralToken);
        console.log("Borrow:", borrowToken);

        vm.startBroadcast(deployerPrivateKey);
        SimpleLender lender = new SimpleLender(
            collateralToken,
            borrowToken,
            interestRate,
            block.chainid
        );
        vm.stopBroadcast();

        console.log("SimpleLender deployed at:", address(lender));

        if (block.chainid == 688689) {
            console.log(string.concat("View: https://atlantic.pharosscan.xyz/address/", vm.toString(address(lender))));
        } else if (block.chainid == 1672) {
            console.log(string.concat("View: https://www.pharosscan.xyz/address/", vm.toString(address(lender))));
        }
    }
}
