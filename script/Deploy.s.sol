// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../contracts/Counter.sol";

/// @title DeployCounter
/// @notice Forge script to deploy Counter to Pharos networks
/// @dev Usage:
///   forge script script/Deploy.s.sol:DeployCounter --rpc-url pharos_testnet --broadcast
///   forge script script/Deploy.s.sol:DeployCounter --rpc-url pharos_testnet --broadcast --verify
contract DeployCounter is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deploying Counter...");
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

        Counter counter = new Counter();

        vm.stopBroadcast();

        console.log("Counter deployed at:", address(counter));

        string memory explorerUrl =
            block.chainid == 688689 ? "https://atlantic.pharosscan.xyz" : "https://www.pharosscan.xyz";
        console.log("Explorer URL:");
        console.log(explorerUrl);
        console.log("Contract address:");
        console.log(address(counter));
    }
}
