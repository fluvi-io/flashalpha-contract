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

  const flashalpha = await ethers.getContractAt("FlashAlpha", "0xcDb625018C3CdfbeB478a74A5b7711B531310fB6");

  /*
  const usdc = await ethers.deployContract("MockERC20", ["Mock USDC", "USDC"]);
  await usdc.deployed();

  await (await usdc.mint(await admin.getAddress(), "100000000000000000000")).wait();

  console.log(flashalpha.address);
  await (await usdc.approve(flashalpha.address, ethers.constants.MaxUint256)).wait();
  await (await flashalpha.deposit(usdc.address, "100000000000000000000", 1)).wait();
  */
  console.log(await flashalpha.callStatic.depositNative(1, {value: "10000000000000000"}))
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
