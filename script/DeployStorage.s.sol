// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Script.sol";
import "../contracts/Storage.sol";

/// @title DeployStorage
/// @notice Forge script to deploy Storage to Pharos networks
/// @dev Usage:
///   forge script script/DeployStorage.s.sol:DeployStorage --rpc-url pharos_testnet --broadcast
contract DeployStorage is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deploying Storage...");
        console.log("Deployer:", deployer);
        console.log("Chain ID:", block.chainid);

        uint256 expectedChainId = vm.envOr("EXPECTED_CHAIN_ID", uint256(0));
        if (expectedChainId != 0 && block.chainid != expectedChainId) {
            revert(
                string(
                    abi.encodePacked(
                        "Wrong chain ID. Expected ", vm.toString(expectedChainId), ", got ", vm.toString(block.chainid)
                    )
                )
            );
        }

        vm.startBroadcast(deployerPrivateKey);

        Storage storage_ = new Storage();

        vm.stopBroadcast();

        console.log("Storage deployed at:", address(storage_));

        string memory explorerUrl =
            block.chainid == 688689 ? "https://atlantic.pharosscan.xyz" : "https://www.pharosscan.xyz";
        console.log("Explorer:", explorerUrl);
        console.log("Address:", address(storage_));
    }
}
