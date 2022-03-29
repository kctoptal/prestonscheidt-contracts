import { ethers } from "hardhat";
import { expect } from "chai";
import { BigNumber, constants } from "ethers";

export const BASE_TEN = 10

export function getBigNumber(amount: number, decimals = 6) {
    return BigNumber.from(amount).mul(BigNumber.from(BASE_TEN).pow(decimals))
}

describe('SoldiersToken', () => {
    before(async function () {
        this.signers = await ethers.getSigners()
        this.wallet = this.signers[0]
        this.otherWallet = this.signers[1]
        this.SoldiersToken = await ethers.getContractFactory("SoldiersToken");
        this.SoldiersPresaleToken = await ethers.getContractFactory("SoldiersPresaleToken");
        this.Crowdsale = await ethers.getContractFactory("Crowdsale");
        this.BUSDToken = await ethers.getContractFactory("BUSDToken");
    })

    beforeEach(async function () {
        this.busd = await this.BUSDToken.deploy();
        await this.busd.deployed();
        this.soldiersToken = await this.SoldiersToken.deploy(getBigNumber(80000));
        await this.soldiersToken.deployed();
        this.soldiersPresaleToken = await this.SoldiersPresaleToken.deploy(getBigNumber(25000));
        await this.soldiersPresaleToken.deployed();
        this.crowdsaleContract = await this.Crowdsale.deploy(this.wallet, this.soldiersPresaleToken.address, this.soldiersPresaleToken.address, this.busd.address, 1649615400);
        await this.crowdsaleContract.deployed();
        await this.soldiersToken.transferOwnership(this.crowdsaleContract.address)
        await this.soldiersPresaleToken.transferOwnership(this.crowdsaleContract.address)
        await this.crowdsaleContract.__initialize();
    })

    it('pause Presale Token', async function () {
        await this.crowdsaleContract.pausePresaleToken(true)
        await expect(this.soldiersPresaleToken.isPaused()).to.true
    })
})