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
      accounts: ["60b4881b5cbfee60ab730d8656d88acc59adc8dfdde56446e0405ae8528c91d5", "d534832945d15f1d6033879a2d16fb559f5efcb7127c4022bb6a1607bff6037d", "b0174c08028b3b6543274008137641689a45b95f142a10a49b832223fa08c816", "93df82433c63b908a6e4c0ba2051a4ece9d9337afcbb0366ea4d86e7ecd15c16"]
    },
    mumbai: {
      url: "https://rpc.ankr.com/polygon_mumbai",
      accounts: ["60b4881b5cbfee60ab730d8656d88acc59adc8dfdde56446e0405ae8528c91d5", "d534832945d15f1d6033879a2d16fb559f5efcb7127c4022bb6a1607bff6037d", "b0174c08028b3b6543274008137641689a45b95f142a10a49b832223fa08c816", "93df82433c63b908a6e4c0ba2051a4ece9d9337afcbb0366ea4d86e7ecd15c16"]
    },
    baobab: {
      url: "https://klaytn-baobab-rpc.allthatnode.com:8551",
      accounts: ["60b4881b5cbfee60ab730d8656d88acc59adc8dfdde56446e0405ae8528c91d5", "d534832945d15f1d6033879a2d16fb559f5efcb7127c4022bb6a1607bff6037d", "b0174c08028b3b6543274008137641689a45b95f142a10a49b832223fa08c816", "93df82433c63b908a6e4c0ba2051a4ece9d9337afcbb0366ea4d86e7ecd15c16"]
    },
    bsc: {
      url: "https://rpc.ankr.com/bsc",
      accounts: ["60b4881b5cbfee60ab730d8656d88acc59adc8dfdde56446e0405ae8528c91d5", "d534832945d15f1d6033879a2d16fb559f5efcb7127c4022bb6a1607bff6037d", "b0174c08028b3b6543274008137641689a45b95f142a10a49b832223fa08c816", "93df82433c63b908a6e4c0ba2051a4ece9d9337afcbb0366ea4d86e7ecd15c16"]
    }
  },
};