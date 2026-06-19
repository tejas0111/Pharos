// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
import {console} from "forge-std/console.sol";

import {Script} from "forge-std/Script.sol";
import {PharosZkLogin} from "../contracts/PharosZkLogin.sol";

/// @title Deploy ZkLogin Verifier
/// @notice Deploy PharosZkLogin for identity abstraction
contract DeployZkLogin is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        PharosZkLogin zkLogin = new PharosZkLogin(block.chainid);

        vm.stopBroadcast();

        console.log("Deployer:", vm.addr(deployerPrivateKey));
        console.log("ZkLogin Verifier:", address(zkLogin));
        console.log("Chain ID:", block.chainid);

        if (block.chainid == 688689) {
            console.log("Explorer: https://atlantic.pharosscan.xyz/address/%s", address(zkLogin));
        } else if (block.chainid == 1672) {
            console.log("Explorer: https://www.pharosscan.xyz/address/%s", address(zkLogin));
        }
    }
}
