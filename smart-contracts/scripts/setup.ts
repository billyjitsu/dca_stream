import { ethers } from "hardhat";

async function main() {

  // const contractedAmount = ethers.parseEther("0.001");

  const contract = await ethers.deployContract("DCA", ["0xe2b8651bF50913057fF47FC4f02A8e12146083B8"]);

  await contract.waitForDeployment();

  console.log(`Contract deployed to ${contract.target}`);

  // Mumbai ETH/USD : 0x009E9B1eec955E9Fe7FE64f80aE868e661cb4729
  // Mumbai USDC/USD : 0x9F8663dD5A0F30a41B774de46128849FE2364C17
  const ethusd = "0x009E9B1eec955E9Fe7FE64f80aE868e661cb4729"
  const usdcusd = "0x9F8663dD5A0F30a41B774de46128849FE2364C17"


  await contract.setProxyAddress(ethusd, usdcusd);
  console.log(`Proxy address set to ${ethusd} and ${usdcusd}`;

  // 0x96b82b65acf7072efeb00502f45757f254c2a0d4    // super maticx
  // 0x42bb40bf79730451b11f6de1cba222f17b87afd7    // super usdc
  const actingEthMaticAddress = "0x96b82b65acf7072efeb00502f45757f254c2a0d4";
  await contract.sendLumpSumToContract(actingEthMaticAddress, ethers.parseEther("2"));
  console.log(`Sent 2 MATIC to contract`);

  //verify contract
  await hre.run("verify:verify", {
   address: contract.target,
   constructorArguments: ["0xe2b8651bF50913057fF47FC4f02A8e12146083B8"],
  });




}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
