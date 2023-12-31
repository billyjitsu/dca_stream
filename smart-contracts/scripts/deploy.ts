import { ethers } from "hardhat";

async function main() {

  // const contractedAmount = ethers.parseEther("0.001");

  const contract = await ethers.deployContract("DCA", ["0xe2b8651bF50913057fF47FC4f02A8e12146083B8"]);

  await contract.waitForDeployment();

  console.log(`Contract deployed to ${contract.target}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
