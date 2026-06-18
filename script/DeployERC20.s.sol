// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Script.sol";
import "../contracts/PharosERC20.sol";

/// @title DeployPharosERC20
/// @notice Forge script to deploy PharosERC20 to Pharos networks
/// @dev Usage:
///   forge script script/DeployERC20.s.sol:DeployPharosERC20 --rpc-url pharos_testnet --broadcast
contract DeployPharosERC20 is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        string memory tokenName = vm.envOr("TOKEN_NAME", string("Pharos Token"));
        string memory tokenSymbol = vm.envOr("TOKEN_SYMBOL", string("PHT"));
        uint256 initialSupply = vm.envOr("INITIAL_SUPPLY", uint256(1_000_000_000e18));

        console.log("Deploying PharosERC20...");
        console.log("Deployer:", deployer);
        console.log("Chain ID:", block.chainid);
        console.log("Token name:", tokenName);
        console.log("Token symbol:", tokenSymbol);
        console.log("Supply:", initialSupply);

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

        PharosERC20 token = new PharosERC20(tokenName, tokenSymbol, initialSupply);

        vm.stopBroadcast();

        console.log("PharosERC20 deployed at:", address(token));

        string memory explorerUrl =
            block.chainid == 688689 ? "https://atlantic.pharosscan.xyz" : "https://www.pharosscan.xyz";
        console.log("Explorer:", explorerUrl);
        console.log("Address:", address(token));
    }
}
