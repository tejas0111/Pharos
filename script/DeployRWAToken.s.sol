// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../contracts/PharosRWAToken.sol";

contract DeployPharosRWAToken is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        string memory tokenName = vm.envOr("RWA_TOKEN_NAME", string("Pharos RealWorld Asset"));
        string memory tokenSymbol = vm.envOr("RWA_TOKEN_SYMBOL", string("pRWA"));
        uint256 initialSupply = vm.envOr("RWA_INITIAL_SUPPLY", uint256(1000000e18));
        uint256 supplyCap = vm.envOr("RWA_SUPPLY_CAP", uint256(100000000e18));

        vm.startBroadcast(deployerPrivateKey);

        uint8 decimals = 18;
        address legalAdmin = deployer;
        PharosRWAToken token = new PharosRWAToken(tokenName, tokenSymbol, decimals, initialSupply, supplyCap, legalAdmin);

        vm.stopBroadcast();

        console.log("Deployer:", deployer);
        console.log("PharosRWAToken deployed at:", address(token));
        console.log("Name:", tokenName);
        console.log("Symbol:", tokenSymbol);
        console.log("Chain ID:", block.chainid);

        if (block.chainid == 688689) {
            console.log("Explorer: https://atlantic.pharosscan.xyz/address/%s", address(token));
        } else if (block.chainid == 1672) {
            console.log("Explorer: https://www.pharosscan.xyz/address/%s", address(token));
        }
    }
}
