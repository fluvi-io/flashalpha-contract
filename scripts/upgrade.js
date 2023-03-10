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

  const flashalpha_impl = await ethers.deployContract("FlashAlpha", ["0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c", await flashalpha.defaultStrategy()]);
  await flashalpha_impl.deployed();

  await (await flashalpha.upgrade(flashalpha_impl.address));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
