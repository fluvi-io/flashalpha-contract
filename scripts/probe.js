// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const ethers = hre.ethers
const utils = ethers.utils
const abi = utils.defaultAbiCoder;

async function main() {

  let _probe = await ethers.deployContract("Probe");

  let probe = (cname) => new Proxy({}, {get (_, fname, __) {return async (...args) => {
      let factory = await ethers.getContractFactory(cname)
      let result = await _probe.callStatic.observe(factory.getDeployTransaction().data, factory.interface.encodeFunctionData(fname, args))
      return factory.interface.decodeFunctionResult(fname, result);
  }}});

  console.log(await probe("Query").getLpTokens());

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});