import { ethers } from "hardhat";
import { expect } from "chai";
import { BigNumber, constants } from "ethers";

export const BASE_TEN = 10

export function getBigNumber(amount: number, decimals = 6) {
    return BigNumber.from(amount).mul(BigNumber.from(BASE_TEN).pow(decimals))
}

describe('SoldiersPresaleToken', () => {
    before(async function () {
        this.signers = await ethers.getSigners()
        this.wallet = this.signers[0]
        this.otherWallet = this.signers[1]
        this.SoldiersPresaleToken = await ethers.getContractFactory("SoldiersPresaleToken");
    })

    beforeEach(async function () {
        this.soldiersPresaleToken = await this.SoldiersPresaleToken.deploy(getBigNumber(25000));
        await this.soldiersPresaleToken.deployed();
        await this.soldiersPresaleToken.mint(getBigNumber(25000))
    })

    it('name', async function () {
        expect(await this.soldiersPresaleToken.name()).to.eq('Pre-Sale SOLDIERS Token')
    })

    it('symbol', async function () {
        expect(await this.soldiersPresaleToken.symbol()).to.eq('$pSLDRS')
    })

    it('decimals', async function () {
        expect(await this.soldiersPresaleToken.decimals()).to.eq(6)
    })

    it('totalSupply', async function () {
        const totalSupply = await this.soldiersPresaleToken.totalSupply()
        console.log(totalSupply)
        expect(totalSupply).to.eq(getBigNumber(25000))
    })

    it('balanceOf', async function () {
        expect(await this.soldiersPresaleToken.balanceOf(this.wallet.address)).to.eq(getBigNumber(25000))
    })

    it('burn', async function () {
        expect(await this.soldiersPresaleToken.transfer(this.otherWallet.address, getBigNumber(100)))
                                                        .to.emit(this.soldiersPresaleToken, 'Transfer')
                                                        .withArgs(this.wallet.address, this.otherWallet.address, getBigNumber(100))
        expect(await this.soldiersPresaleToken.totalSupply()).to.eq(getBigNumber(25000))
        expect(await this.soldiersPresaleToken.balanceOf(this.otherWallet.address)).to.eq(getBigNumber(100))
        expect(await this.soldiersPresaleToken.balanceOf(this.wallet.address)).to.eq(getBigNumber(25000 - 100))
        expect(await this.soldiersPresaleToken.burn(this.otherWallet.address, getBigNumber(50)))
                                                        .to.emit(this.soldiersPresaleToken, 'Transfer')
                                                        .withArgs(this.otherWallet.address, constants.AddressZero, getBigNumber(50))
        expect(await this.soldiersPresaleToken.balanceOf(this.otherWallet.address)).to.eq(getBigNumber(50))
    })

    it('isPaused', async function () {
        expect(await this.soldiersPresaleToken.isPaused()).to.false
    })

    it('pause', async function () {
        await expect(this.soldiersPresaleToken.pause()).to.emit(this.soldiersPresaleToken, 'Pause')
        expect(await this.soldiersPresaleToken.isPaused()).to.true
    })

    it('unpause', async function () {
        await expect(this.soldiersPresaleToken.pause()).to.emit(this.soldiersPresaleToken, 'Pause')
        expect(await this.soldiersPresaleToken.isPaused()).to.true
        await expect(this.soldiersPresaleToken.unpause()).to.emit(this.soldiersPresaleToken, 'Unpause')
        expect(await this.soldiersPresaleToken.isPaused()).to.false
    })

    it('pause when token is already paused', async function () {
        await expect(this.soldiersPresaleToken.pause()).to.emit(this.soldiersPresaleToken, 'Pause')
        expect(await this.soldiersPresaleToken.isPaused()).to.true
        await expect(this.soldiersPresaleToken.pause()).to.revertedWith('Token Paused')
    })

    it('unpause when token is already unpaused', async function () {
        await expect(this.soldiersPresaleToken.pause()).to.emit(this.soldiersPresaleToken, 'Pause')
        expect(await this.soldiersPresaleToken.isPaused()).to.true
        await expect(this.soldiersPresaleToken.unpause()).to.emit(this.soldiersPresaleToken, 'Unpause')
        expect(await this.soldiersPresaleToken.isPaused()).to.false
        await expect(this.soldiersPresaleToken.unpause()).to.revertedWith('Token Not Paused')
    })

    it('transfer when unPaused', async function () {
        await expect(this.soldiersPresaleToken.transfer(this.otherWallet.address, getBigNumber(100)))
                                                        .to.emit(this.soldiersPresaleToken, 'Transfer')
                                                        .withArgs(this.wallet.address, this.otherWallet.address, getBigNumber(100))
        expect(await this.soldiersPresaleToken.totalSupply()).to.eq(getBigNumber(25000))
        expect(await this.soldiersPresaleToken.balanceOf(this.wallet.address)).to.eq(getBigNumber(25000 - 100))
        expect(await this.soldiersPresaleToken.balanceOf(this.otherWallet.address)).to.eq(getBigNumber(100))
        expect(await this.soldiersPresaleToken.isPaused()).to.false
    })

    it('transfer when Paused', async function () {
        expect(await this.soldiersPresaleToken.balanceOf(this.wallet.address)).to.eq(getBigNumber(25000))
        expect(await this.soldiersPresaleToken.isPaused()).to.false //Token is unpaused
        await expect(this.soldiersPresaleToken.pause()).to.emit(this.soldiersPresaleToken, 'Pause')
        expect(await this.soldiersPresaleToken.isPaused()).to.true //Token is paused
        await expect(this.soldiersPresaleToken.transfer(this.otherWallet.address, getBigNumber(25)))
                                                .to.revertedWith('Token Paused')
        expect(await this.soldiersPresaleToken.balanceOf(this.wallet.address)).to.eq(getBigNumber(25000))
        expect(await this.soldiersPresaleToken.balanceOf(this.otherWallet.address)).to.eq(getBigNumber(0))
    })

    it('Approve when unPaused', async function () {
        expect(await this.soldiersPresaleToken.totalSupply()).to.eq(getBigNumber(25000))
        expect(await this.soldiersPresaleToken.balanceOf(this.wallet.address)).to.eq(getBigNumber(25000))
        expect(await this.soldiersPresaleToken.isPaused()).to.false //Token is unpaused

        await expect(this.soldiersPresaleToken.approve(this.otherWallet.address, getBigNumber(75)))
                                                        .to.emit(this.soldiersPresaleToken, 'Approval')
                                                        .withArgs(this.wallet.address, this.otherWallet.address, getBigNumber(75))
    })

    it('Approve when paused', async function () {
        expect(await this.soldiersPresaleToken.totalSupply()).to.eq(getBigNumber(25000))
        expect(await this.soldiersPresaleToken.balanceOf(this.wallet.address)).to.eq(getBigNumber(25000))
        
        await expect(this.soldiersPresaleToken.pause()).to.emit(this.soldiersPresaleToken, 'Pause')
        expect(await this.soldiersPresaleToken.isPaused()).to.true //Token is paused
        await expect(this.soldiersPresaleToken.approve(this.otherWallet.address, getBigNumber(75)))
                                                        .to.revertedWith('Token Paused')
    })

    it('Allowance', async function () {
        expect(await this.soldiersPresaleToken.totalSupply()).to.eq(getBigNumber(25000))
        expect(await this.soldiersPresaleToken.balanceOf(this.wallet.address)).to.eq(getBigNumber(25000))
        expect(await this.soldiersPresaleToken.isPaused()).to.false //Token is unpaused

        await expect(this.soldiersPresaleToken.approve(this.otherWallet.address, getBigNumber(75)))
                                                        .to.emit(this.soldiersPresaleToken, 'Approval')
                                                        .withArgs(this.wallet.address, this.otherWallet.address, getBigNumber(75))
        expect(await this.soldiersPresaleToken.allowance(this.wallet.address, this.otherWallet.address)).to.eq(getBigNumber(75))
    })

    it('transferFrom when unPaused', async function () {
        expect(await this.soldiersPresaleToken.totalSupply()).to.eq(getBigNumber(25000))
        expect(await this.soldiersPresaleToken.balanceOf(this.wallet.address)).to.eq(getBigNumber(25000))
        expect(await this.soldiersPresaleToken.isPaused()).to.false //Token is unpaused

        await expect(this.soldiersPresaleToken.approve(this.otherWallet.address, getBigNumber(75)))
                                                        .to.emit(this.soldiersPresaleToken, 'Approval')
                                                        .withArgs(this.wallet.address, this.otherWallet.address, getBigNumber(75))
        expect(await this.soldiersPresaleToken.allowance(this.wallet.address, this.otherWallet.address)).to.eq(getBigNumber(75))

        await expect(this.soldiersPresaleToken.transferFrom(this.wallet.address, this.otherWallet.address, getBigNumber(75)))
                                                .to.emit(this.soldiersPresaleToken, 'Transfer')
                                                .withArgs(this.wallet.address, this.otherWallet.address, getBigNumber(75))
        expect(await this.soldiersPresaleToken.balanceOf(this.otherWallet.address)).to.eq(getBigNumber(75))
        expect(await this.soldiersPresaleToken.balanceOf(this.wallet.address)).to.eq(getBigNumber(25000 - 75))
    })

    it('transferFrom when paused', async function () {
        expect(await this.soldiersPresaleToken.totalSupply()).to.eq(getBigNumber(25000))
        expect(await this.soldiersPresaleToken.balanceOf(this.wallet.address)).to.eq(getBigNumber(25000))
        expect(await this.soldiersPresaleToken.isPaused()).to.false //Token is unpaused

        await expect(this.soldiersPresaleToken.approve(this.otherWallet.address, getBigNumber(75)))
                                                        .to.emit(this.soldiersPresaleToken, 'Approval')
                                                        .withArgs(this.wallet.address, this.otherWallet.address, getBigNumber(75))
        expect(await this.soldiersPresaleToken.allowance(this.wallet.address, this.otherWallet.address)).to.eq(getBigNumber(75))

        await expect(this.soldiersPresaleToken.pause()).to.emit(this.soldiersPresaleToken, 'Pause')
        expect(await this.soldiersPresaleToken.isPaused()).to.true //Token is paused
        await expect(this.soldiersPresaleToken.transferFrom(this.wallet.address, this.otherWallet.address, getBigNumber(75)))
                                                        .to.revertedWith('Token Paused')
    })
})