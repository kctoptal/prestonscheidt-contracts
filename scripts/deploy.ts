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
  const wallet = deployer.address;
  const startTime = 1651516200;
  const pancakeRouter = '0xD99D1c33F9fC3444f8101754aBC46c52416550D1';

  const SoldiersPresaleToken = await ethers.getContractFactory("SoldiersPresaleToken");
  const presaleSoldiers = await SoldiersPresaleToken.deploy(getBigNumber(55000), startTime, busdTokenAddress, wallet);
  await presaleSoldiers.deployed();
  console.log("Soldiers Presale Token deployed to :", presaleSoldiers.address);

  const BarracksToken = await ethers.getContractFactory("BarracksToken");
  const barracksToken = await BarracksToken.deploy(getBigNumber(80000));
  await barracksToken.deployed();
  console.log("Barracks Token deployed to :", barracksToken.address);
  const SoldiersToken = await ethers.getContractFactory("SoldiersToken");
  const soldiers = await SoldiersToken.deploy(getBigNumber(80000), startTime, presaleSoldiers.address, 
                                                    busdTokenAddress, barracksToken.address, pancakeRouter, wallet);
  await soldiers.deployed();
  console.log("Soldiers Token deployed to :", soldiers.address);

  const presaleOwnerTx = await presaleSoldiers.transferOwnership(soldiers.address);
  await presaleOwnerTx.wait();
  console.log("Presale Soldiers Contract Ownership transferred successfully");

  const barackTokenSupply = await barracksToken.totalSupply();
  await barracksToken.approve(soldiers.address, barackTokenSupply);
  console.log("P2 Token approval to Soldiers Token done successfully");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});