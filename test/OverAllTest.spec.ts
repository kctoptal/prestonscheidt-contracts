import { ethers } from "hardhat";
import { expect } from "chai";
import { BigNumber, constants } from "ethers";

export const BASE_TEN = 10

export function getBigNumber(amount: number, decimals = 18) {
    return BigNumber.from(amount).mul(BigNumber.from(BASE_TEN).pow(decimals))
}

describe('SoldiersToken', () => {
    before(async function () {
        this.signers = await ethers.getSigners()
        this.wallet = this.signers[0]
        this.otherWallet = this.signers[1]
        this.SoldiersPresaleToken = await ethers.getContractFactory("SoldiersPresaleToken");
        this.BUSDToken = await ethers.getContractFactory("BUSDToken");
        this.BarracksToken = await ethers.getContractFactory("BarracksToken");
        this.SoldiersToken = await ethers.getContractFactory("SoldiersToken");
    })

    beforeEach(async function () {
        this.busdContract = await this.BUSDToken.deploy();
        await this.busdContract.deployed();
        this.p2Contract = await this.BarracksToken.deploy(getBigNumber(80000));
        await this.p2Contract.deployed();
        this.preSaleContract = await this.SoldiersPresaleToken.deploy(getBigNumber(55000), 1649615400, this.busdContract.address, this.wallet.address);
        await this.preSaleContract.deployed();
        this.saleContract = await this.SoldiersToken.deploy(getBigNumber(80000), 1649615400, this.preSaleContract.address, this.busdContract.address, this.p2Contract.address, '0xD99D1c33F9fC3444f8101754aBC46c52416550D1', this.wallet.address);
        await this.saleContract.deployed();
        await this.preSaleContract.transferOwnership(this.saleContract.address);
        const p2TokenSupply = await this.p2Contract.totalSupply();
        await this.p2Contract.approve(this.saleContract.address, p2TokenSupply);
    })

    it('Slot1 Presale', async function () {
        const c1 = await this.saleContract.setSaleStartTime(1651084200)
        c1.wait()
        await this.saleContract.setPreSaleSlot3Window(7, 604800)
        await this.saleContract.setPreSaleSlot2Window(14, 604800)
        await this.saleContract.setPreSaleSlot1Window(21, 604800)

        console.log('Total Pre-Sale tokens =', await this.preSaleContract.balanceOf(this.signers[1].address))
        console.log("PreSale Stage = ", await this.saleContract.getStageOfSale());
        console.log('Rate =', await this.preSaleContract.preSaleSlot1rate());
        const mintTx = await this.busdContract.mint(this.signers[1].address, getBigNumber(100))
        mintTx.wait();
        const approvTx = await this.busdContract.connect(this.signers[1]).approve(this.preSaleContract.address, getBigNumber(100))
        approvTx.wait()
        console.log('BUSD Allowance = ', await this.busdContract.allowance(this.signers[1].address, this.preSaleContract.address))
        console.log('Prior to buy total presale token =', await this.preSaleContract.balanceOf(this.signers[1].address))
        const buyTx = await this.preSaleContract.connect(this.signers[1]).buy(10000000)
        buyTx.wait()
        console.log('Total Pre-Sale tokens =', await this.preSaleContract.balanceOf(this.signers[1].address))
    })

    it('Slot2 Presale', async function () {
        const c1 = await this.saleContract.setSaleStartTime(1650479400)
        c1.wait()
        await this.saleContract.setPreSaleSlot3Window(7, 604800)
        await this.saleContract.setPreSaleSlot2Window(14, 604800)
        await this.saleContract.setPreSaleSlot1Window(21, 604800)

        console.log('Total Pre-Sale tokens =', await this.preSaleContract.balanceOf(this.signers[1].address))
        console.log("PreSale Stage = ", await this.saleContract.getStageOfSale());
        console.log('Rate =', await this.preSaleContract.preSaleSlot2rate());
        const mintTx = await this.busdContract.mint(this.signers[1].address, getBigNumber(150))
        mintTx.wait();
        const approvTx = await this.busdContract.connect(this.signers[1]).approve(this.preSaleContract.address, getBigNumber(150))
        approvTx.wait()
        console.log('BUSD Allowance = ', await this.busdContract.allowance(this.signers[1].address, this.preSaleContract.address))
        console.log('Prior to buy total presale token =', await this.preSaleContract.balanceOf(this.signers[1].address))
        await this.saleContract.addAddressesToWhitelist([this.signers[1].address, this.signers[2].address])
        console.log('Is Signer 2 Whitelisted =', await this.preSaleContract.whitelist(this.signers[2].address))
        const buyTx = await this.preSaleContract.connect(this.signers[1]).buy(10000000)
        buyTx.wait()
        await this.saleContract.removeAddressesFromWhitelist([this.signers[1].address, this.signers[2].address])
        console.log('Is Signer 2 Whitelisted =', await this.preSaleContract.whitelist(this.signers[2].address))
        console.log('Total Pre-Sale tokens =', await this.preSaleContract.balanceOf(this.signers[1].address))
    })

    it('Slot3 Presale', async function () {
        const c1 = await this.saleContract.setSaleStartTime(1649874600)
        c1.wait()
        await this.saleContract.setPreSaleSlot3Window(7, 604800)
        await this.saleContract.setPreSaleSlot2Window(14, 604800)
        await this.saleContract.setPreSaleSlot1Window(21, 604800)

        console.log("PreSale Stage = ", await this.saleContract.getStageOfSale());
        console.log('Rate =', await this.preSaleContract.preSaleSlot3rate());
        console.log('Total Pre-Sale tokens =', await this.preSaleContract.balanceOf(this.signers[1].address))
        const mintTx = await this.busdContract.mint(this.signers[1].address, getBigNumber(200))
        mintTx.wait();
        const approvTx = await this.busdContract.connect(this.signers[1]).approve(this.preSaleContract.address, getBigNumber(200))
        approvTx.wait()
        console.log('BUSD Allowance = ', await this.busdContract.allowance(this.signers[1].address, this.preSaleContract.address))
        console.log('Prior to buy total presale token =', await this.preSaleContract.balanceOf(this.signers[1].address))
        const buyTx = await this.preSaleContract.connect(this.signers[1]).buy(10000000)
        buyTx.wait()
        console.log('Total Pre-Sale tokens =', await this.preSaleContract.balanceOf(this.signers[1].address))
    })

    it('Redemption & Staking Test', async function () {
        console.log("PreSale Owner =", await this.preSaleContract.owner());
        console.log("PreSale totalSupply =", await this.preSaleContract.totalSupply());
        console.log("Sale Owner =", await this.saleContract.owner());
        console.log("Sale totalSupply =", await this.saleContract.totalSupply());

        console.log("PreSale Stage = ", await this.preSaleContract.getStageOfSale());
        const mintTx = await this.busdContract.mint(this.signers[1].address, getBigNumber(200))
        mintTx.wait();
        const approvTx = await this.busdContract.connect(this.signers[1]).approve(this.preSaleContract.address, getBigNumber(200))
        approvTx.wait()
        console.log('BUSD Allowance = ', await this.busdContract.allowance(this.signers[1].address, this.preSaleContract.address))
        console.log('Prior to buy total presale token =', await this.preSaleContract.balanceOf(this.signers[1].address))
        const buyTx = await this.preSaleContract.connect(this.signers[1]).buy(10000000)
        buyTx.wait()
        console.log('Post Buy total presale tokens', await this.preSaleContract.balanceOf(this.signers[1].address))
        
        console.log("Is Sale Started = ", await this.saleContract.isSaleStarted());
        const c1 = await this.saleContract.setSaleStartTime(1649529000)
        c1.wait()
        await this.saleContract.setRedemptionWindow(0, 604800)
        await this.saleContract.setP2TokenSwapWindow(3, 604800)
        console.log("Is Sale Started = ", await this.saleContract.isSaleStarted());

        const redemtx = await this.saleContract.connect(this.signers[1]).redemption(10000000)
        redemtx.wait()
        console.log('Post Redemption total presale tokens =', await this.preSaleContract.balanceOf(this.signers[1].address))
        console.log('Post Redemption total Sale tokens =', await this.saleContract.balanceOf(this.signers[1].address))
        
        const stakingAddress = await this.saleContract.staking();

        console.log('Staking balance =', await this.saleContract.balanceOf(stakingAddress))
        await this.saleContract.connect(this.signers[1]).stakeToken(3000000)
        console.log('Post Staking total Sale tokens =', await this.saleContract.balanceOf(this.signers[1].address))
        console.log('Staked Data =', await this.saleContract.getStakedData(this.signers[1].address))
        await new Promise(f => setTimeout(f, 100));
        await this.saleContract.connect(this.signers[1]).stakeToken(2000000)
        console.log('Post 2nd Staking total Sale tokens =', await this.saleContract.balanceOf(this.signers[1].address))
        console.log('Staking balance =', await this.saleContract.balanceOf(stakingAddress))
        await new Promise(f => setTimeout(f, 1000));
        await this.saleContract.connect(this.signers[1]).claimStakedInterest()
        console.log('Staked Data Post Claim =', await this.saleContract.getStakedData(this.signers[1].address))
        await new Promise(f => setTimeout(f, 100));
        await this.saleContract.connect(this.signers[1]).unstakeToken()
        console.log('Staked Data Post Unstake=', await this.saleContract.getStakedData(this.signers[1].address))
        console.log('Staking balance =', await this.saleContract.balanceOf(stakingAddress))
        await new Promise(f => setTimeout(f, 100));
        await this.saleContract.connect(this.signers[1]).claimStakedInterest()
        console.log('Staked Data Post Unstaked Claim =', await this.saleContract.getStakedData(this.signers[1].address))
        await this.saleContract.connect(this.signers[1]).claimStakedInterest()
        await new Promise(f => setTimeout(f, 100));
        console.log('Staked Data Post Unstaked Claim 2nd attempt =', await this.saleContract.getStakedData(this.signers[1].address))
        console.log('Post 1st Iteration of Claim total Sale tokens with Interest =', await this.saleContract.balanceOf(this.signers[1].address))

        console.log('########### 2st round of stake & unstake ###########')
        console.log('Staking balance =', await this.saleContract.balanceOf(stakingAddress))
        await this.saleContract.connect(this.signers[1]).stakeToken(3000000)
        console.log('Post Staking total Sale tokens =', await this.saleContract.balanceOf(this.signers[1].address))
        console.log('Staked Data =', await this.saleContract.getStakedData(this.signers[1].address))
        await new Promise(f => setTimeout(f, 100));
        await this.saleContract.connect(this.signers[1]).stakeToken(2000000)
        console.log('Post 2nd Staking total Sale tokens =', await this.saleContract.balanceOf(this.signers[1].address))
        console.log('Staking balance =', await this.saleContract.balanceOf(stakingAddress))
        await new Promise(f => setTimeout(f, 1000));
        await this.saleContract.connect(this.signers[1]).claimStakedInterest()
        console.log('Staked Data Post Claim =', await this.saleContract.getStakedData(this.signers[1].address))
        await new Promise(f => setTimeout(f, 100));
        await this.saleContract.connect(this.signers[1]).unstakeToken()
        console.log('Staked Data Post Unstake=', await this.saleContract.getStakedData(this.signers[1].address))
        await new Promise(f => setTimeout(f, 100));
        await this.saleContract.connect(this.signers[1]).claimStakedInterest()
        console.log('Staked Data Post Unstaked Claim =', await this.saleContract.getStakedData(this.signers[1].address))
        console.log('Staking balance =', await this.saleContract.balanceOf(stakingAddress))
        console.log('Post 2nd Iteration of Claim total Sale tokens with Interest =', await this.saleContract.balanceOf(this.signers[1].address))
    })

    it('Referral', async function () {
        console.log('Pre Referral Total Sale tokens =', await this.saleContract.balanceOf(this.signers[2].address))
        await this.saleContract.referral(this.signers[2].address, 500)
        console.log('Post Referral Total Sale tokens =', await this.saleContract.balanceOf(this.signers[2].address))
    })

    it('Sell', async function () {
        console.log('Pre Transfer Total Sale tokens =', await this.saleContract.balanceOf(this.signers[1].address))
        await this.saleContract.transfer(this.signers[1].address, 10000000)
        console.log('Post Transfer Total Sale tokens =', await this.saleContract.balanceOf(this.signers[1].address))
        console.log("Sale Stage = ", await this.saleContract.getStageOfSale());
        const c1 = await this.saleContract.setSaleStartTime(1649529000)
        c1.wait()
        await this.saleContract.setPreSaleSlot3Window(7, 604800)
        await this.saleContract.setPreSaleSlot2Window(14, 604800)
        await this.saleContract.setPreSaleSlot1Window(21, 604800)
        await this.saleContract.setRedemptionWindow(0, 604800)
        await this.saleContract.setP2TokenSwapWindow(3, 604800)
        console.log("Is Sale Started = ", await this.saleContract.isSaleStarted());
        console.log("Sale Stage = ", await this.saleContract.getStageOfSale());
    })
})