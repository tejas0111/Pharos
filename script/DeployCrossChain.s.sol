// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {CrossChainMessage} from "../contracts/CrossChainMessage.sol";

contract DeployCrossChain is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deploying CrossChainMessage...");
        console.log("Deployer:", deployer);
        console.log("Chain ID:", block.chainid);

        vm.startBroadcast(deployerPrivateKey);
        CrossChainMessage xchain = new CrossChainMessage(block.chainid);
        vm.stopBroadcast();

        console.log("CrossChainMessage deployed at:", address(xchain));

        if (block.chainid == 688689) {
            console.log(string.concat("View: https://atlantic.pharosscan.xyz/address/", vm.toString(address(xchain))));
        } else if (block.chainid == 1672) {
            console.log(string.concat("View: https://www.pharosscan.xyz/address/", vm.toString(address(xchain))));
        }

        console.log("");
        console.log("To register peers, call:");
        console.log(string.concat("cast send ", vm.toString(address(xchain)), " registerPeer(uint256,address) <peerChainId> <peerContract> --rpc-url <rpc> --private-key <key>"));
    }
}
