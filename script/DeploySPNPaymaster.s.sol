// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
import {console} from "forge-std/console.sol";

import {Script} from "forge-std/Script.sol";
import {PharosSPNPaymaster} from "../contracts/PharosSPNPaymaster.sol";

/// @title Deploy SPN Paymaster
/// @notice Deploy PharosSPNPaymaster to sponsor user transactions
contract DeploySPNPaymaster is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address entryPoint = vm.envOr("ENTRYPOINT_ADDRESS", address(0x0000000071727De22E5E9d8BAf0edAc6f37da032));

        vm.startBroadcast(deployerPrivateKey);

        PharosSPNPaymaster paymaster = new PharosSPNPaymaster(entryPoint, block.chainid);

        vm.stopBroadcast();

        console.log("Deployer:", vm.addr(deployerPrivateKey));
        console.log("SPN Paymaster:", address(paymaster));
        console.log("EntryPoint:", entryPoint);
        console.log("Chain ID:", block.chainid);

        if (block.chainid == 688689) {
            console.log("Explorer: https://atlantic.pharosscan.xyz/address/%s", address(paymaster));
        } else if (block.chainid == 1672) {
            console.log("Explorer: https://www.pharosscan.xyz/address/%s", address(paymaster));
        }

        console.log("");
        console.log("Post-deploy: Add sponsored users");
        console.log("cast send --private-key $PRIVATE_KEY %s \"addSponsor(address)\" <USER_ADDRESS>", address(paymaster));
        console.log("cast send --private-key $PRIVATE_KEY %s \"setGlobalBudget(uint256)\" <BUDGET_IN_WEI>", address(paymaster));
    }
}
