import { ethers } from "hardhat";
import { Wallet } from "ethers";
import { BigNumber, constants } from "ethers";

export const BASE_TEN = 10

export function getBigNumber(amount: number, decimals = 18) {
    return BigNumber.from(amount).mul(BigNumber.from(BASE_TEN).pow(decimals))
}

async function main() {
    const preSaleAddress = "0x1d378dD142e3BeBB3b2A7B2D73DEcD03DBBFF2fd";  //Rinkeby deployed address
    const busdAddress = "0x202E70B186412d0F65C60868d030A651C4d6F643";
    const p2Address = "0xC1aF50fef7D753d39A0Cd71cAF13581803615Bc9";
    const saleAddress = "0x58901668260577DA30a86dd715261bf5C16C0820";

    const preSaleContract = await ethers.getContractAt("SoldiersPresaleToken", preSaleAddress);
    const busdContract = await ethers.getContractAt("BUSDToken", busdAddress);
    const p2Contract = await ethers.getContractAt("BarracksToken", p2Address);
    const saleContract = await ethers.getContractAt("SoldiersToken", saleAddress);

    const signers = await ethers.getSigners()
//   const accounts = [signers[1].address, signers[2].address, signers[3].address, signers[4].address, signers[5].address]
  const accounts = ["0xDA50FF6D7e4C4D4458cc9DE70fA82045A525CA58", "0x63249b8F042e2FDebF7d3fD7001Ad234CE57A75a", "0xf94258cECD257EEcE5498326028a82776dBfe309"]
  const provider = ethers.getDefaultProvider();

//   console.log("PreSale Owner =", await preSaleContract.owner());
//   console.log("PreSale totalSupply =", await preSaleContract.totalSupply());
//   console.log("Sale Owner =", await saleContract.owner());
//   console.log("Sale totalSupply =", await saleContract.totalSupply());

//   console.log("PreSale Stage = ", await preSaleContract.getStageOfSale());
//   const mintTx = await busdContract.mint(signers[1].address, getBigNumber(200))
//   mintTx.wait();
//   const approvTx = await busdContract.connect(signers[1]).approve(preSaleContract.address, getBigNumber(200))
//   approvTx.wait()
//   console.log('Prior to buy total presale token =', await preSaleContract.balanceOf(signers[1].address))
//   const buyTx = await preSaleContract.connect(signers[1]).buy(10000000)
//   buyTx.wait()
//   console.log('Post Buy total presale tokens', await preSaleContract.balanceOf(signers[1].address))
  
//   console.log("Is Sale Started = ", await saleContract.isSaleStarted());
//   const c1 = await saleContract.setSaleStartTime(1649529000)
//   c1.wait()
//   await saleContract.setRedemptionWindow(0, 604800)
//   await saleContract.setP2TokenSwapWindow(3, 604800)
//   console.log("Is Sale Started = ", await saleContract.isSaleStarted());

//   const redemtx = await saleContract.connect(signers[1]).redemption(10000000)
//   redemtx.wait()
//   console.log('Post Redemption total presale tokens =', await preSaleContract.balanceOf(signers[1].address))
//   console.log('Post Redemption total Sale tokens =', await saleContract.balanceOf(signers[1].address))

// ########################### Sell Txn Started ##########################
    // console.log('Pre Transfer Total Sale tokens =', await saleContract.balanceOf(accounts[1]))
    // const tx = await saleContract.transfer(accounts[1], 10000000)
    // tx.wait()
    // console.log('Post Transfer Total Sale tokens =', await saleContract.balanceOf(accounts[1]))
    // console.log("Sale Stage = ", await saleContract.getStageOfSale());
    // const c1 = await saleContract.setSaleStartTime(1649529000)
    // c1.wait()
    // await new Promise(f => setTimeout(f, 1000));
    // await saleContract.setPreSaleSlot3Window(7, 604800)
    // await saleContract.setPreSaleSlot2Window(14, 604800)
    // await saleContract.setPreSaleSlot1Window(21, 604800)
    // await saleContract.setRedemptionWindow(0, 604800)
    // await saleContract.setP2TokenSwapWindow(3, 604800)
    // await new Promise(f => setTimeout(f, 1000));
    // console.log("Is Sale Started = ", await saleContract.isSaleStarted());
    // console.log("Sale Stage = ", await saleContract.getStageOfSale());
    
    // const mintTx = await busdContract.mint(accounts[0], getBigNumber(150000))
    // mintTx.wait();
    // const approvTx = await busdContract.approve(saleContract.address, getBigNumber(150000))
    // approvTx.wait()
    // console.log('Balance of BUSD in Owner account =', await busdContract.balanceOf(accounts[0]))
    // console.log('Balance of Owner =', await saleContract.balanceOf(accounts[0]))
    // console.log('Balance of BUSD in Sale Token Contract =', await busdContract.balanceOf(saleContract.address))
    // console.log('Balance of Sale Token Contract =', await saleContract.balanceOf(saleContract.address))
    // console.log('Allowance for BUSD to router =', await busdContract.allowance(saleContract.address, '0xD99D1c33F9fC3444f8101754aBC46c52416550D1'))
    // console.log('Allowance for Sale Token to router =', await saleContract.allowance(saleContract.address, '0xD99D1c33F9fC3444f8101754aBC46c52416550D1'))
    // await saleContract.addLiquidity(getBigNumber(150000))
    // console.log('Balance of BUSD in Owner account =', await busdContract.balanceOf(accounts[0]))
    // console.log('Balance of Owner =', await saleContract.balanceOf(accounts[0]))
    // console.log('Balance of BUSD in Sale Token Contract =', await busdContract.balanceOf(saleContract.address))
    // console.log('Balance of Sale Token Contract =', await saleContract.balanceOf(saleContract.address))
    // await new Promise(f => setTimeout(f, 2000));
    // console.log('Balance of BUSD in Seller account =', await busdContract.balanceOf(accounts[1]))
    // console.log('Balance of BUSD in Owner =', await busdContract.balanceOf(accounts[0]))
    // await saleContract.connect(accounts[1]).sell(10000000)
    // await new Promise(f => setTimeout(f, 2000));
    // console.log('Balance of BUSD in Seller account =', await busdContract.balanceOf(accounts[1]))
    // console.log('Balance of BUSD in Owner =', await busdContract.balanceOf(accounts[0]))

    console.log("Sale Stage = ", await saleContract.getStageOfSale());
    const c1 = await saleContract.setSaleStartTime(1649097000)
    c1.wait()
    await new Promise(f => setTimeout(f, 1000));
    await saleContract.setPreSaleSlot3Window(7, 604800)
    await saleContract.setPreSaleSlot2Window(14, 604800)
    await saleContract.setPreSaleSlot1Window(21, 604800)
    await saleContract.setRedemptionWindow(0, 604800)
    await saleContract.setP2TokenSwapWindow(3, 604800)
    await new Promise(f => setTimeout(f, 1000));
    console.log("Sale Stage = ", await saleContract.getStageOfSale());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
