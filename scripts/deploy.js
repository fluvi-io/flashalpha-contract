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

  let deployer;
  if (true) {
    const Deployer = await ethers.getContractFactory("Deployer");
    deployer = await Deployer.deploy({gasLimit: 5000000});
    deployer.deployed();
  } else {
    console.log("s")
    deployer = await ethers.getContractAt("Deployer", "0x12C20D5B3DAb1A51e4ABA6cA80522ec76e8Bf956")
  }
  
  const salt = "0xf0dd352ee83d66c7939e912c3877327275ca3f9a1cf75aa54a5d57a2b495a5e2";
  const endpointAddress = await deployer.computeAddress(salt);

  const Cloner = await ethers.getContractFactory("Cloner");
  const cloner = await Cloner.deploy(deployer.address, {gasLimit: 5000000});
  await cloner.deployed();

  await (await deployer.grantRole(await deployer.DEPLOYER(), cloner.address)).wait()

  
  const receiverProxy = await ethers.deployContract("ReceiverProxy");
  await receiverProxy.deployed();

  const hodlStrategy = await ethers.deployContract("HodlStrategy", [endpointAddress]);
  await hodlStrategy.deployed();


  const flashalpha_impl = await ethers.deployContract("FlashAlpha", ["0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c", hodlStrategy.address]);
  await flashalpha_impl.deployed();
  

  await (await cloner.clone(receiverProxy.address, salt, receiverProxy.interface.encodeFunctionData("___initializeProxy", [flashalpha_impl.address, flashalpha_impl.interface.encodeFunctionData("initialize")]), {gasLimit: 5000000})).wait();

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
