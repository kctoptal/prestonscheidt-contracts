import { ethers } from "hardhat";
import { BigNumber } from "ethers";

const BASE_TEN = 10
function getBigNumber(amount: number, decimals = 6) {
  return BigNumber.from(amount).mul(BigNumber.from(BASE_TEN).pow(decimals))
}

async function main() {
  const networkName = (await ethers.provider.getNetwork()).name;
  const chainid = (await ethers.provider.getNetwork()).chainId;
  const [deployer] = await ethers.getSigners();
  
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Network name=", networkName);
  console.log("Network chain id=", chainid);

  const SoldiersPresaleToken = await ethers.getContractFactory("SoldiersPresaleToken");
  const presaleSoldiers = await SoldiersPresaleToken.deploy(getBigNumber(55000));
  await presaleSoldiers.deployed();
  console.log("Soldiers Presale Token deployed to :", presaleSoldiers.address);

  const SoldiersToken = await ethers.getContractFactory("SoldiersToken");
  const soldiers = await SoldiersToken.deploy(getBigNumber(80000));
  await soldiers.deployed();
  console.log("Soldiers Token deployed to :", soldiers.address);

  let busdTokenAddress;
  if(chainid == 56) {
    busdTokenAddress = '0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56'; //BSC BUSD address
  } else {
    const BUSDToken = await ethers.getContractFactory("BUSDToken");
    const busd = await BUSDToken.deploy();
    await busd.deployed();
    busdTokenAddress = busd.address;
    console.log("BUSD Test Token deployed to :", busd.address);
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});