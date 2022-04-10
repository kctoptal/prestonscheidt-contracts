// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import './interfaces/Burnable.sol';
import './interfaces/IPancakeRouter02.sol';
import './interfaces/IPancakeFactory.sol';
import "./libraries/SafeMath.sol";
import './tokens/PausableToken.sol';
import './SoldiersPresaleToken.sol';
import './Staking.sol';

contract SoldiersToken is PausableToken, Burnable {
    using SafeMath for uint;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event UpdatePancakeSwapV2Router(address indexed newAddress, address indexed oldAddress);

    uint public constant MAX_REFERRAL_SUPPLY = 2000;
    uint public constant MAX_LIMIT_SELL = 500;
    uint public constant MAX_LIQUIDITY_SUPPLY = 5000;

    string public constant override name = 'SOLDIERS Token';
    string public constant override symbol = '$SLDRS';
    uint8 public constant override decimals = 6;

    uint public saleStartTime;
    IPancakeRouter02 public pancakeRrouter;
    address public pancakeswapV2Pair;
    Staking public staking;

    // The busd token
    address public busdToken;
    // The presale token
    address public presaleToken;
    // The project 2 token
    address public p2Token;
    // Address where BUSD funds are collected
    address public wallet;
    
    mapping (address => bool) private _isExcludedFromTax;

    uint public redemptionStartTime;
    uint public redemptionEndTime;
    uint public p2TokenSwapStartTime;
    uint public p2TokenSwapEndTime;

    // Referral Supply of Sale token
    uint public referralSupply;
    uint8 public transferTaxPercent = 75;

    constructor(
        uint256 _initialSupply,
        uint _saleStartTime,
        address _presaleToken,
        address _busdToken,
        address _p2Token,
        address _router,
        address _wallet
    ) {
        saleStartTime = _saleStartTime;
        presaleToken = _presaleToken;
        busdToken = _busdToken;
        p2Token = _p2Token;
        wallet = _wallet;

        pancakeRrouter = IPancakeRouter02(_router);
        address _pancakeswapV2Pair = IPancakeFactory(pancakeRrouter.factory())
            .createPair(address(this), address(busdToken));
        pancakeswapV2Pair = _pancakeswapV2Pair;
        staking = new Staking();

        excludeAccountFromTax(owner(), true);
        excludeAccountFromTax(address(this), true);
        excludeAccountFromTax(address(staking), true);

        referralSupply = MAX_REFERRAL_SUPPLY.mul(multiplier());
        redemptionStartTime = saleStartTime;
        redemptionEndTime = redemptionStartTime + (7 * 24 * 60 * 60);
        p2TokenSwapStartTime = saleStartTime + (3 * 24 * 60 * 60);
        redemptionEndTime = p2TokenSwapStartTime + (7 * 24 * 60 * 60);
        _mint(owner(), _initialSupply);
    }

    function approve(address _spender, uint256 _value) public override returns (bool) {
       return super.approve(_spender, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function burn(address _holder, uint _value) external onlyOwner override returns (bool) {
        return _burn(_holder, _value);
    }
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public override onlyOwner {
        excludeAccountFromTax(owner(), false);
        excludeAccountFromTax(newOwner, true);
        super._transferOwnership(newOwner);
    }
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferPresaleTokenOwnership(address newOwner) public onlyOwner {
        SoldiersPresaleToken(presaleToken).transferOwnership(newOwner);
    }
    /**
     * @dev Function returns stage of sale at any point in time
     */
    function isSaleStarted() external view returns(bool) {
        if(block.timestamp >= saleStartTime) {
            return true;
        }
        return false;
    }
    /**
     * @dev Function returns stage of sale at any point in time
     */
    function getStageOfSale() external view returns(SoldiersPresaleToken.CrowdsaleStage) {
        return SoldiersPresaleToken(presaleToken).getStageOfSale();
    }
    function excludeAccountFromTax(address account, bool excluded) public onlyOwner() {
        require(_isExcludedFromTax[account] != excluded, "Account is already the value of 'excluded'");
        _isExcludedFromTax[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }
    /**
     * @dev Function to to update Pancake Swap router
     * @param newAddress new address of Pancake Swap V2 router
     */
    function updatePancakeswapV2Router(address newAddress) external onlyOwner {
        require(newAddress != address(pancakeRrouter), "The router already has that address");
        pancakeRrouter = IPancakeRouter02(newAddress);
        address _pancakeswapV2Pair = IPancakeFactory(pancakeRrouter.factory())
            .createPair(address(this), address(busdToken));
        pancakeswapV2Pair = _pancakeswapV2Pair;
        emit UpdatePancakeSwapV2Router(newAddress, address(pancakeRrouter));
    }
    /**
     * @dev Function to stake or deposit sale token
     * @param _numberOfUnits Number of SLDRs in smallest unit to be staked
     */
    function stakeToken(uint _numberOfUnits) external {
        require(_numberOfUnits > 0, 'Number of Units is Zero');
        require(balanceOf[msg.sender] >= _numberOfUnits, 'Insufficient balance');

        _transfer(msg.sender, address(staking), _numberOfUnits);
        staking.stakeToken(msg.sender, _numberOfUnits);
    }
    /**
     * @dev Function to unstake or withdraw principal staked sale token
     */
    function unstakeToken() external {
        uint totalStakedAmount = staking.unstakeToken(msg.sender);
        if(totalStakedAmount > 0) {
            require(totalStakedAmount <= balanceOf[address(staking)], 'Insufficient balance');
            _transfer(address(staking), msg.sender, totalStakedAmount);
        }
    }
    /**
     * @dev Function to claim staked interest in sale token
     */
    function claimStakedInterest() external {
        uint totalInterest = staking.claimStakedInterest(msg.sender);
        if(totalInterest > 0) {
            _burn(owner(), totalInterest.mul(5).div(100));
            _transfer(owner(), msg.sender, totalInterest.mul(95).div(100));
        }
    }
    /**
     * @dev Function to get staked info for an address
     * @param _wallet Wallet address for which query for staking info being made
     */
    function getStakedData(address _wallet) external view returns(Staking.StakedInfo[] memory) {
        return staking.getStakedData(_wallet);
    }
    /**
     * @dev Function to sell sale token in wei
     * @param _numberOfUnits Number of SLDRS in smallest unit to buy
     */
    function sell(uint _numberOfUnits) external {
        require(block.timestamp >= saleStartTime && block.timestamp < p2TokenSwapEndTime, 'Sell not allowed');
        require(_numberOfUnits <= MAX_LIMIT_SELL.mul(multiplier()), 'Above max limit to sell');
        if(block.timestamp < p2TokenSwapStartTime) { //75% tax on sale
            _transfer(msg.sender, msg.sender, _numberOfUnits);
        } else if(block.timestamp >= p2TokenSwapStartTime && block.timestamp < p2TokenSwapEndTime) { // Exchange with P2 token
            _transfer(msg.sender, address(this), _numberOfUnits);
            IERC20(p2Token).transferFrom(owner(), msg.sender, _numberOfUnits);
        }
    }
    /**
     * @dev Function to redeem pre sale token to sale token
     * @param _numberOfUnits Number of pSLDRs in smallest unit to be redeemed
     */
    function redemption(uint _numberOfUnits) external {
        require(_numberOfUnits > 0, 'Number of Units is Zero');
        require(block.timestamp >= redemptionStartTime && block.timestamp < redemptionEndTime, 'Not in Redemption period');
        Burnable(presaleToken).burn(msg.sender, _numberOfUnits);
        _transfer(owner(), msg.sender, _numberOfUnits);
    }
    /**
     * @dev Function to send referral token to a given address
     * @param _to Wallet address to whome referral is sent
     * @param _amount Amount of Soldiers token to be given as referral
     */
    function referral(address _to, uint _amount) external onlyOwner {
        require(_amount <= referralSupply, 'Max Referral amount exhausted');
        referralSupply -= _amount;
        _transfer(owner(), _to, _amount);
    }
    /**
     * @dev Function to set sale start time
     * @param _saleStartTimestamp sale start time
     */
    function setSaleStartTime(uint _saleStartTimestamp) external onlyOwner {
        saleStartTime = _saleStartTimestamp;
        SoldiersPresaleToken(presaleToken).setSaleStartTime(_saleStartTimestamp);
    }
    /**
     * @dev Function to set Redemption window w.r.t sale start time
     * @param _daysAfter number of days prior to sale start time
     * @param _durationInSecs duration of redemption in seconds or epoch from redemption start time
     */
    function setRedemptionWindow(uint _daysAfter, uint _durationInSecs) external onlyOwner {
        redemptionStartTime = saleStartTime + (_daysAfter * 24 * 60 * 60);
        redemptionEndTime = redemptionStartTime + _durationInSecs;
    }
    /**
     * @dev Function to set P2 Token swap window w.r.t sale start time
     * @param _daysAfter number of days prior to sale start time
     * @param _durationInSecs duration of P2 token swap in seconds or epoch from p2 token swap start time
     */
    function setP2TokenSwapWindow(uint _daysAfter, uint _durationInSecs) external onlyOwner {
        p2TokenSwapStartTime = saleStartTime + (_daysAfter * 24 * 60 * 60);
        p2TokenSwapEndTime = p2TokenSwapStartTime + _durationInSecs;
    }
    /**
     * @dev Function to set Transfer tax percent
     * @param newtaxPercent new tax percentage value
     */
    function setTransferTaxPercent(uint8 newtaxPercent) external onlyOwner {
        require(newtaxPercent != transferTaxPercent, 'Same value as existing');
        transferTaxPercent = newtaxPercent;
    }
    /**
     * @dev Function to set Liquidity in Pancake swap
     * @param _busdAmount Amount of BUSD token to be added for liquidity for 5000 SLDRS token
     */
    function addLiquidity(uint _busdAmount) external onlyOwner {
        uint _tokenAmount = MAX_LIQUIDITY_SUPPLY.mul(multiplier());

        IERC20(busdToken).transferFrom(owner(), address(this), _busdAmount);
        IERC20(busdToken).approve(address(pancakeRrouter), _busdAmount);

        //Get Liquidity Supply amount transferred to this contract
        _transfer(owner(), address(this), _tokenAmount);

        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(pancakeRrouter), _tokenAmount);

        // // add the liquidity
        pancakeRrouter.addLiquidity(
            address(this),
            address(busdToken),
            _tokenAmount,
            _busdAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            wallet,
            block.timestamp
        );
    }
    function _transfer(address _sender, address _recipient, uint _amount) internal override {
        if (_isExcludedFromTax[_sender] || _isExcludedFromTax[_recipient]) {
            super._transfer(_sender, _recipient, _amount);
        } else if(block.timestamp >= saleStartTime && block.timestamp < p2TokenSwapStartTime){
            uint busdAmount = IERC20(busdToken).balanceOf(address(staking));
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = address(busdToken);

            //Transfer the amount to this contract from Seller
            super._transfer(_sender, address(this), _amount);
            _approve(address(this), address(pancakeRrouter), _amount);

            // make the swap
            pancakeRrouter.swapExactTokensForTokens(
                _amount,
                0, // accept any amount of BUSD
                path,
                address(staking),
                block.timestamp
            );
            uint busdAmountPostSwap = IERC20(busdToken).balanceOf(address(staking));

            (uint adjustedAmount, uint taxAmount) = calculateTransactionTax(busdAmountPostSwap.sub(busdAmount), transferTaxPercent);
            staking.distributeSwappedToken(busdToken, _recipient, wallet, adjustedAmount, taxAmount);
        }
    }
    /**
     * @dev Function to set pre sale slot1 rate in BUSD in wei
     * @param _rate Amount of BUSD in wei per small unit to buy
     */
    function setPreSaleSlot1Rate(uint _rate) external onlyOwner {
        SoldiersPresaleToken(presaleToken).setPreSaleSlot1Rate(_rate);
    }
    /**
     * @dev Function to set pre-sale slot1 window w.r.t sale start time
     * @param _daysPrior number of days prior to sale start time
     * @param _durationInSecs duration of presale in seconds or epoch from slot1 start time
     */
    function setPreSaleSlot1Window(uint _daysPrior, uint _durationInSecs) external onlyOwner {
        SoldiersPresaleToken(presaleToken).setPreSaleSlot1Window(_daysPrior, _durationInSecs);
    }
    /**
     * @dev Function to set pre sale slot1 rate in BUSD in wei
     * @param _rate Amount of BUSD in wei per small unit to buy
     */
    function setPreSaleSlot2Rate(uint _rate) external onlyOwner {
        SoldiersPresaleToken(presaleToken).setPreSaleSlot2Rate(_rate);
    }
    /**
     * @dev Function to set pre-sale slot2 window w.r.t sale start time
     * @param _daysPrior number of days prior to sale start time
     * @param _durationInSecs duration of presale in seconds or epoch from slot1 start time
     */
    function setPreSaleSlot2Window(uint _daysPrior, uint _durationInSecs) external onlyOwner {
        SoldiersPresaleToken(presaleToken).setPreSaleSlot2Window(_daysPrior, _durationInSecs);
    }
    /**
     * @dev Function to set public presale or slot3 rate in BUSD in wei
     * @param _rate Amount of BUSD in wei per small unit to buy
     */
    function setPreSaleSlot3Rate(uint _rate) external onlyOwner {
        SoldiersPresaleToken(presaleToken).setPreSaleSlot3Rate(_rate);
    }
    /**
     * @dev Function to set pre-sale slot3 window w.r.t sale start time
     * @param _daysPrior number of days prior to sale start time
     * @param _durationInSecs duration of presale in seconds or epoch from slot3 start time
     */
    function setPreSaleSlot3Window(uint _daysPrior, uint _durationInSecs) external onlyOwner {
        SoldiersPresaleToken(presaleToken).setPreSaleSlot3Window(_daysPrior, _durationInSecs);
    }
    /**
     * @dev add an address to the whitelist
     * @param addr address
     * @return success if the address was added to the whitelist, false if the address was already in the whitelist
     */
    function addAddressToWhitelist(address addr) onlyOwner public returns(bool success) {
        return SoldiersPresaleToken(presaleToken).addAddressToWhitelist(addr);
    }
    /**
     * @dev add addresses to the whitelist
     * @param addrs addresses
     * @return success if at least one address was added to the whitelist,
     * false if all addresses were already in the whitelist
     */
    function addAddressesToWhitelist(address[] memory addrs) onlyOwner public returns(bool success) {
        return SoldiersPresaleToken(presaleToken).addAddressesToWhitelist(addrs);
    }
    /**
     * @dev remove an address from the whitelist
     * @param addr address
     * @return success if the address was removed from the whitelist,
     * false if the address wasn't in the whitelist in the first place
     */
    function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {
        return SoldiersPresaleToken(presaleToken).removeAddressFromWhitelist(addr);
    }
    /**
     * @dev remove addresses from the whitelist
     * @param addrs addresses
     * @return success if at least one address was removed from the whitelist,
     * false if all addresses weren't in the whitelist in the first place
     */
    function removeAddressesFromWhitelist(address[] memory addrs) onlyOwner public returns(bool success) {
        return SoldiersPresaleToken(presaleToken).removeAddressesFromWhitelist(addrs);
    }
    function calculateTransactionTax(uint256 _value, uint8 _tax) internal pure returns (uint256 adjustedValue, uint256 taxAmount){
        taxAmount = _value.mul(_tax).div(100);
        adjustedValue = _value.mul(SafeMath.sub(100, _tax)).div(100);
        return (adjustedValue, taxAmount);
    }
    function multiplier() internal pure returns(uint) {
        return 10**decimals;
    }
}