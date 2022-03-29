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
    })

    beforeEach(async function () {
        this.soldiersToken = await this.SoldiersToken.deploy(getBigNumber(80000));
        await this.soldiersToken.deployed();
        await this.soldiersToken.mint(getBigNumber(80000))
    })

    it('name', async function () {
        expect(await this.soldiersToken.name()).to.eq('SOLDIERS Token')
    })

    it('symbol', async function () {
        expect(await this.soldiersToken.symbol()).to.eq('$SLDRS')
    })

    it('decimals', async function () {
        expect(await this.soldiersToken.decimals()).to.eq(6)
    })

    it('totalSupply', async function () {
        const totalSupply = await this.soldiersToken.totalSupply()
        console.log(totalSupply)
        expect(totalSupply).to.eq(getBigNumber(80000))
    })

    it('balanceOf', async function () {
        expect(await this.soldiersToken.balanceOf(this.wallet.address)).to.eq(getBigNumber(80000))
    })

    it('burn', async function () {
        expect(await this.soldiersToken.transfer(this.otherWallet.address, getBigNumber(100)))
                                                        .to.emit(this.soldiersToken, 'Transfer')
                                                        .withArgs(this.wallet, this.otherWallet.address, getBigNumber(100))
        expect(await this.soldiersToken.totalSupply()).to.eq(getBigNumber(80000))
        expect(await this.soldiersToken.balanceOf(this.otherWallet.address)).to.eq(getBigNumber(100))
        expect(await this.soldiersToken.balanceOf(this.wallet.address)).to.eq(getBigNumber(80000 - 100))
        expect(await this.soldiersToken.burn(this.otherWallet.address, getBigNumber(50)))
                                                        .to.emit(this.soldiersToken, 'Transfer')
                                                        .withArgs(this.otherWallet.address, constants.AddressZero, getBigNumber(50))
        expect(await this.soldiersToken.balanceOf(this.otherWallet.address)).to.eq(getBigNumber(50))
    })

    it('isPaused', async function () {
        expect(await this.soldiersToken.isPaused()).to.false
    })

    it('pause', async function () {
        await expect(this.soldiersToken.pause()).to.emit(this.soldiersToken, 'Pause')
        expect(await this.soldiersToken.isPaused()).to.true
    })

    it('unpause', async function () {
        await expect(this.soldiersToken.pause()).to.emit(this.soldiersToken, 'Pause')
        expect(await this.soldiersToken.isPaused()).to.true
        await expect(this.soldiersToken.unpause()).to.emit(this.soldiersToken, 'Unpause')
        expect(await this.soldiersToken.isPaused()).to.false
    })

    it('pause when token is already paused', async function () {
        await expect(this.soldiersToken.pause()).to.emit(this.soldiersToken, 'Pause')
        expect(await this.soldiersToken.isPaused()).to.true
        await expect(this.soldiersToken.pause()).to.revertedWith('Token Paused')
    })

    it('unpause when token is already unpaused', async function () {
        await expect(this.soldiersToken.pause()).to.emit(this.soldiersToken, 'Pause')
        expect(await this.soldiersToken.isPaused()).to.true
        await expect(this.soldiersToken.unpause()).to.emit(this.soldiersToken, 'Unpause')
        expect(await this.soldiersToken.isPaused()).to.false
        await expect(this.soldiersToken.unpause()).to.revertedWith('Token Not Paused')
    })

    it('transfer when unPaused', async function () {
        await expect(this.soldiersToken.transfer(this.otherWallet.address, getBigNumber(100)))
                                                        .to.emit(this.soldiersToken, 'Transfer')
                                                        .withArgs(this.wallet.address, this.otherWallet.address, getBigNumber(100))
        expect(await this.soldiersToken.totalSupply()).to.eq(getBigNumber(80000))
        expect(await this.soldiersToken.balanceOf(this.wallet.address)).to.eq(getBigNumber(80000 - 100))
        expect(await this.soldiersToken.balanceOf(this.otherWallet.address)).to.eq(getBigNumber(100))
        expect(await this.soldiersToken.isPaused()).to.false
    })

    it('transfer when Paused', async function () {
        expect(await this.soldiersToken.balanceOf(this.wallet.address)).to.eq(getBigNumber(80000))
        expect(await this.soldiersToken.isPaused()).to.false //Token is unpaused
        await expect(this.soldiersToken.pause()).to.emit(this.soldiersToken, 'Pause')
        expect(await this.soldiersToken.isPaused()).to.true //Token is paused
        await expect(this.soldiersToken.transfer(this.otherWallet.address, getBigNumber(25)))
                                                .to.revertedWith('Token Paused')
        expect(await this.soldiersToken.balanceOf(this.wallet.address)).to.eq(getBigNumber(80000))
        expect(await this.soldiersToken.balanceOf(this.otherWallet.address)).to.eq(getBigNumber(0))
    })

    it('Approve when unPaused', async function () {
        expect(await this.soldiersToken.totalSupply()).to.eq(getBigNumber(80000))
        expect(await this.soldiersToken.balanceOf(this.wallet.address)).to.eq(getBigNumber(80000))
        expect(await this.soldiersToken.isPaused()).to.false //Token is unpaused

        await expect(this.soldiersToken.approve(this.otherWallet.address, getBigNumber(75)))
                                                        .to.emit(this.soldiersToken, 'Approval')
                                                        .withArgs(this.wallet.address, this.otherWallet.address, getBigNumber(75))
    })

    it('Approve when paused', async function () {
        expect(await this.soldiersToken.totalSupply()).to.eq(getBigNumber(80000))
        expect(await this.soldiersToken.balanceOf(this.wallet.address)).to.eq(getBigNumber(80000))
        
        await expect(this.soldiersToken.pause()).to.emit(this.soldiersToken, 'Pause')
        expect(await this.soldiersToken.isPaused()).to.true //Token is paused
        await expect(this.soldiersToken.approve(this.otherWallet.address, getBigNumber(75)))
                                                        .to.revertedWith('Token Paused')
    })

    it('Allowance', async function () {
        expect(await this.soldiersToken.totalSupply()).to.eq(getBigNumber(80000))
        expect(await this.soldiersToken.balanceOf(this.wallet.address)).to.eq(getBigNumber(80000))
        expect(await this.soldiersToken.isPaused()).to.false //Token is unpaused

        await expect(this.soldiersToken.approve(this.otherWallet.address, getBigNumber(75)))
                                                        .to.emit(this.soldiersToken, 'Approval')
                                                        .withArgs(this.wallet.address, this.otherWallet.address, getBigNumber(75))
        expect(await this.soldiersToken.allowance(this.wallet.address, this.otherWallet.address)).to.eq(getBigNumber(75))
    })

    it('transferFrom when unPaused', async function () {
        expect(await this.soldiersToken.totalSupply()).to.eq(getBigNumber(80000))
        expect(await this.soldiersToken.balanceOf(this.wallet.address)).to.eq(getBigNumber(80000))
        expect(await this.soldiersToken.isPaused()).to.false //Token is unpaused

        await expect(this.soldiersToken.approve(this.otherWallet.address, getBigNumber(75)))
                                                        .to.emit(this.soldiersToken, 'Approval')
                                                        .withArgs(this.wallet.address, this.otherWallet.address, getBigNumber(75))
        expect(await this.soldiersToken.allowance(this.wallet.address, this.otherWallet.address)).to.eq(getBigNumber(75))

        await expect(this.soldiersToken.transferFrom(this.wallet.address, this.otherWallet.address, getBigNumber(75)))
                                                .to.emit(this.soldiersToken, 'Transfer')
                                                .withArgs(this.wallet.address, this.otherWallet.address, getBigNumber(75))
        expect(await this.soldiersToken.balanceOf(this.otherWallet.address)).to.eq(getBigNumber(75))
        expect(await this.soldiersToken.balanceOf(this.wallet.address)).to.eq(getBigNumber(80000 - 75))
    })

    it('transferFrom when paused', async function () {
        expect(await this.soldiersToken.totalSupply()).to.eq(getBigNumber(80000))
        expect(await this.soldiersToken.balanceOf(this.wallet.address)).to.eq(getBigNumber(80000))
        expect(await this.soldiersToken.isPaused()).to.false //Token is unpaused

        await expect(this.soldiersToken.approve(this.otherWallet.address, getBigNumber(75)))
                                                        .to.emit(this.soldiersToken, 'Approval')
                                                        .withArgs(this.wallet.address, this.otherWallet.address, getBigNumber(75))
        expect(await this.soldiersToken.allowance(this.wallet.address, this.otherWallet.address)).to.eq(getBigNumber(75))

        await expect(this.soldiersToken.pause()).to.emit(this.soldiersToken, 'Pause')
        expect(await this.soldiersToken.isPaused()).to.true //Token is paused
        await expect(this.soldiersToken.transferFrom(this.wallet.address, this.otherWallet.address, getBigNumber(75)))
                                                        .to.revertedWith('Token Paused')
    })
})