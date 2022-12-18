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

  const flashalpha_impl = await ethers.deployContract("FlashAlpha", ["0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889", "0x17e808Df4eA1b292d68703f84675C72DB0F859A8"]);
  await flashalpha_impl.deployed();

  await (await flashalpha.upgrade(flashalpha_impl.address));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
