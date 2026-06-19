// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {DEXPool} from "../contracts/DEXPool.sol";

contract DeployDEXPool is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        address tokenA = vm.envAddress("TOKEN_A");
        address tokenB = vm.envAddress("TOKEN_B");

        console.log("Deploying DEXPool...");
        console.log("Deployer:", deployer);
        console.log("Token A:", tokenA);
        console.log("Token B:", tokenB);

        vm.startBroadcast(deployerPrivateKey);
        DEXPool pool = new DEXPool(tokenA, tokenB, block.chainid);
        vm.stopBroadcast();

        console.log("DEXPool deployed at:", address(pool));

        if (block.chainid == 688689) {
            console.log(string.concat("View: https://atlantic.pharosscan.xyz/address/", vm.toString(address(pool))));
        } else if (block.chainid == 1672) {
            console.log(string.concat("View: https://www.pharosscan.xyz/address/", vm.toString(address(pool))));
        }
    }
}
