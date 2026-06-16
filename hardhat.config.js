require("@nomicfoundation/hardhat-toolbox");

task("deploy", "Deploy contracts to Pharos")
  .addParam("contract", "Contract name (e.g., Counter)")
  .setAction(async (taskArgs, hre) => {
    const factory = await hre.ethers.getContractFactory(taskArgs.contract);
    const contract = await factory.deploy();
    await contract.waitForDeployment();
    console.log(`${taskArgs.contract} deployed to:`, await contract.getAddress());
  });

task("verify", "Verify contract on PharosScan")
  .addParam("address", "Contract address")
  .addParam("contract", "Fully qualified name (e.g. contracts/Counter.sol:Counter)")
  .setAction(async (taskArgs, hre) => {
    await hre.run("verify:verify", {
      address: taskArgs.address,
      contract: taskArgs.contract,
    });
  });

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.26",
    settings: {
      evmVersion: "cancun",
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    pharosTestnet: {
      url: process.env.PHAROS_TESTNET_RPC_URL || "https://atlantic.dplabs-internal.com",
      chainId: 688689,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    },
    pharosMainnet: {
      url: process.env.PHAROS_MAINNET_RPC_URL || "https://rpc.pharos.xyz",
      chainId: 1672,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    },
  },
  etherscan: {
    apiKey: {
      pharosTestnet: process.env.PHAROSSCAN_API_KEY || "",
      pharosMainnet: process.env.PHAROSSCAN_API_KEY || "",
    },
    customChains: [
      {
        network: "pharosTestnet",
        chainId: 688689,
        urls: {
          apiURL: "https://atlantic.pharosscan.xyz/api",
          browserURL: "https://atlantic.pharosscan.xyz",
        },
      },
      {
        network: "pharosMainnet",
        chainId: 1672,
        urls: {
          apiURL: "https://www.pharosscan.xyz/api",
          browserURL: "https://www.pharosscan.xyz",
        },
      },
    ],
  },
};
