require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },
  mocha: {
    timeout: 100000000
  },
  networks: {
    hardhat: {
    },
    goerli: {
      url: "https://rpc.ankr.com/eth_goerli",
      accounts: [process.env.FLASHALPHA_DEPLOYER]
    },
    mumbai: {
      url: "https://rpc.ankr.com/polygon_mumbai",
      accounts: [process.env.FLASHALPHA_DEPLOYER]
    },
    baobab: {
      url: "https://klaytn-baobab-rpc.allthatnode.com:8551",
      accounts: [process.env.FLASHALPHA_DEPLOYER]
    },
    bsc: {
      url: "https://rpc.ankr.com/bsc",
      accounts: [process.env.FLASHALPHA_DEPLOYER]
    },
    polygon: {
      url: "https://rpc-mainnet.matic.quiknode.pro",
      accounts: [process.env.FLASHALPHA_DEPLOYER]
    }
  },
};