// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const ethers = hre.ethers;
async function main() {
  const [admin, relayer, user, authenticator] = await ethers.getSigners();

  const flashalpha = await ethers.getContractAt("FlashAlpha", "0x84a88e78147be7ee6c1a6f2dba616522437208ff");
  const flashBorrowerDemo = await ethers.deployContract("FlashBorrowerDemo", [flashalpha.address], {gasPrice: 500});
  await flashBorrowerDemo.deployed();

  //const flashBorrowerDemo = await ethers.getContractAt("FlashBorrowerDemo", "0x26FaD55E94D7db571339ffdb08F3EDB6B2f86430");
  const USDT = await ethers.getContractAt("IERC20", "0x55d398326f99059fF775485246999027B3197955");

  await (await USDT.transfer(flashBorrowerDemo.address, "1100000000000000000")).wait();

  await (await flashBorrowerDemo.step1()).wait();

  //console.log(await flashBorrowerDemo.callStatic.step2());
  //await (await flashBorrowerDemo.step2()).wait();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
