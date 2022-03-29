// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import './interfaces/IERC20.sol';
import './interfaces/Mintable.sol';
import "./libraries/SafeMath.sol";
import './tokens/PausableToken.sol';
import './Ownable.sol';

contract Crowdsale is Ownable {
    using SafeMath for uint;

    // Crowdsale Stages
    enum CrowdsaleStage { NOTSTARTED, PRESALE_STAGE1, PRESALE_STAGE2, SALE }

    // Default to presale stage
    CrowdsaleStage internal stage = CrowdsaleStage.PRESALE_STAGE1;

    uint public constant MAX_REFERRAL_SUPPLY = 2000;
    uint public constant MAX_STAKING_INTEREST_SUPPLY = 18000;
    uint public constant MAX_LIQUIDITY_SUPPLY = 5000;
    uint public constant MAX_PRESALE_SLOT1_SUPPLY = 5000;
    uint public constant MAX_PRESALE_SLOT2_SUPPLY = 20000;

    // The presale token
    address public busdToken;
    // The presale token
    address public presaleToken;
    // The sale token
    address public saleToken;
    // Address where funds are collected
    address public wallet;
    
    // How many token units a buyer gets per BUSD in wei
    uint public preSaleSlot1rate = 10000000000000;
    uint public presaleSlot1StartTime;
    uint public presaleSlot1EndTime;

    uint public preSaleSlot2rate = 15000000000000;
    uint public presaleSlot2StartTime;
    uint public presaleSlot2EndTime;

    uint public rate = 20000000000000;
    uint public saleStartTime;
    //uint public saleEndTime;

    uint public redemptionStartTime;
    uint public redemptionEndTime;

    constructor(
        address _wallet,
        address _presaleToken,
        address _saleToken,
        address _busdToken,
        uint _saleStartTime
    ) {
        require(keccak256(abi.encodePacked(IERC20(_busdToken).symbol())) == keccak256(abi.encodePacked("BUSD")));
        require(_wallet != address(0));
        saleStartTime = _saleStartTime;
        presaleToken = _presaleToken;
        saleToken = _saleToken;
        busdToken = _busdToken;
        wallet = _wallet;

        presaleSlot1StartTime = _saleStartTime - (14 * 24 * 60 * 60);
        presaleSlot1EndTime = presaleSlot1StartTime + (7 * 24 * 60 * 60);
        presaleSlot2StartTime = _saleStartTime - (7 * 24 * 60 * 60);
        presaleSlot2EndTime = presaleSlot2StartTime + (7 * 24 * 60 * 60);
        //saleEndTime = _saleStartTime + (7 * 24 * 60 * 60);
        redemptionStartTime = saleStartTime;
        redemptionEndTime = redemptionStartTime + (7 * 24 * 60 * 60);
    }

    function __initialize() external onlyOwner {
        uint presaleTotalSupply = Mintable(presaleToken).initialSupply();
        uint saleTotalSupply = Mintable(saleToken).initialSupply();
        Mintable(presaleToken).mint(presaleTotalSupply);
        Mintable(saleToken).mint(saleTotalSupply);
    }

    /**
     * @dev Function to buy pre sale token in BUSD in wei
     * @param _numberOfUnits Number of pSLDRs in smallest unit to buy
     */
    function buy(uint _numberOfUnits) external {
        require(block.timestamp >= presaleSlot1StartTime, 'Presale Not started');
        require(_numberOfUnits > 0, 'Number of Units is Zero');
        if(block.timestamp < presaleSlot2EndTime) {
            buyPresale(_numberOfUnits);
        } else {
            buySale(_numberOfUnits);
        }
    }
    /**
     * @dev Function to redeem pre sale token to sale token
     * @param _numberOfUnits Number of pSLDRs in smallest unit to be redeemed
     */
    function redemption(uint _numberOfUnits) external {
        require(_numberOfUnits > 0, 'Number of Units is Zero');
        require(block.timestamp >= redemptionStartTime && block.timestamp < redemptionEndTime, 'Not in Redemption period');
        Mintable(presaleToken).burn(msg.sender, _numberOfUnits);
        IERC20(saleToken).transfer(msg.sender, _numberOfUnits);
    }
    /**
     * @dev Function returns stage of sale at any point in time
     */
    function getStageOfSale() external view returns(CrowdsaleStage) {
        if(block.timestamp < presaleSlot1StartTime) {
            return CrowdsaleStage.NOTSTARTED;
        } else if(block.timestamp >= presaleSlot1StartTime && block.timestamp < presaleSlot1EndTime) {
            return CrowdsaleStage.PRESALE_STAGE1;
        } else if(block.timestamp >= presaleSlot2StartTime && block.timestamp < presaleSlot2EndTime) {
            return CrowdsaleStage.PRESALE_STAGE2;
        } else if(block.timestamp >= saleStartTime) {
            return CrowdsaleStage.SALE;
        }
    }
    /**
     * @dev Function to pause or unpause presale token
     * @param _value Boolean value True to pause and False to unpause
     */
    function pausePresaleToken(bool _value) public onlyOwner {
        if(_value) {
            PausableToken(presaleToken).pause();
        } else {
            PausableToken(presaleToken).unpause();
        }
    }
    /**
     * @dev Function to pause or unpause sale token
     * @param _value Boolean value True to pause and False to unpause
     */
    function pauseSaleToken(bool _value) public onlyOwner {
        if(_value) {
            PausableToken(saleToken).pause();
        } else {
            PausableToken(saleToken).unpause();
        }
    }
    /**
     * @dev Function to set public sale rate in BUSD in wei
     * @param _rate Amount of BUSD in wei per small unit to buy
     */
    function setRate(uint _rate) public onlyOwner {
        require(_rate > 0, 'Sale Rate is 0');
        rate = _rate;
    }
    /**
     * @dev Function to set sale start time
     * @param _saleStartTimestamp sale start time
     */
    function setSaleStartTime(uint _saleStartTimestamp) public onlyOwner {
        saleStartTime = _saleStartTimestamp;
    }
    /**
     * @dev Function to set pre sale slot1 rate in BUSD in wei
     * @param _rate Amount of BUSD in wei per small unit to buy
     */
    function setPreSaleSlot1Rate(uint _rate) public onlyOwner {
        require(_rate > 0, 'Presale Slot1 Rate is 0');
        preSaleSlot1rate = _rate;
    }
    /**
     * @dev Function to set pre-sale slot1 window w.r.t sale start time
     * @param _daysPrior number of days prior to sale start time
     * @param _durationInSecs duration of presale in seconds or epoch from slot1 start time
     */
    function setPreSaleSlot1Window(uint _daysPrior, uint _durationInSecs) public onlyOwner {
        presaleSlot1StartTime = saleStartTime - (_daysPrior * 24 * 60 * 60);
        presaleSlot1EndTime = presaleSlot1StartTime + _durationInSecs;
        require(presaleSlot1EndTime <= presaleSlot2StartTime, 'Presale Slot1 end time greater than sale time');
    }
    /**
     * @dev Function to set pre sale slot1 rate in BUSD in wei
     * @param _rate Amount of BUSD in wei per small unit to buy
     */
    function setPreSaleSlot2Rate(uint _rate) public onlyOwner {
        require(_rate > 0, 'Presale Slot2 Rate is 0');
        preSaleSlot2rate = _rate;
    }
    /**
     * @dev Function to set pre-sale slot2 window w.r.t sale start time
     * @param _daysPrior number of days prior to sale start time
     * @param _durationInSecs duration of presale in seconds or epoch from slot1 start time
     */
    function setPreSaleSlot2Window(uint _daysPrior, uint _durationInSecs) public onlyOwner {
        presaleSlot2StartTime = saleStartTime - (_daysPrior * 24 * 60 * 60);
        presaleSlot2EndTime = presaleSlot2StartTime + _durationInSecs;
        require(presaleSlot2EndTime <= saleStartTime, 'Presale slot2 end time greater than sale time');
    }

    /**
     * @dev Function to set pre-sale slot2 window w.r.t sale start time
     * @param _daysAfter number of days prior to sale start time
     * @param _durationInSecs duration of presale in seconds or epoch from slot1 start time
     */
    function setRedemptionWindow(uint _daysAfter, uint _durationInSecs) public onlyOwner {
        redemptionStartTime = saleStartTime + (_daysAfter * 24 * 60 * 60);
        redemptionEndTime = redemptionStartTime + _durationInSecs;
    }
    /**
     * @dev Function to buy pre sale token in BUSD in wei
     * @param _numberOfUnits Number of pSLDRs in smallest unit to buy
     */
    function buyPresale(uint _numberOfUnits) internal {
        uint _rate;
        uint _soldTokens = IERC20(presaleToken).totalSupply() - IERC20(presaleToken).balanceOf(address(this));
        if(block.timestamp < presaleSlot1EndTime) {
            _rate = preSaleSlot1rate;
            require(_soldTokens + _numberOfUnits <= MAX_PRESALE_SLOT1_SUPPLY.mul(multiplier()), 'Presale Slot1 limit crossed');
        } else if(block.timestamp >= presaleSlot2StartTime && block.timestamp < presaleSlot2EndTime) {
            _rate = preSaleSlot2rate;
            require(_soldTokens + _numberOfUnits <= (MAX_PRESALE_SLOT1_SUPPLY + MAX_PRESALE_SLOT2_SUPPLY).mul(multiplier()), 'Presale Slot2 limit crossed');
        }
        uint _amount = _numberOfUnits.mul(_rate);
        IERC20(busdToken).transferFrom(msg.sender, wallet, _amount);
        IERC20(presaleToken).transfer(msg.sender, _numberOfUnits);
    }

    function buySale(uint _numberOfUnits) internal {
        uint _soldPresaleTokens = IERC20(presaleToken).totalSupply() - IERC20(presaleToken).balanceOf(address(this));
        if(block.timestamp >= saleStartTime){
            require(_numberOfUnits + _soldPresaleTokens + (MAX_REFERRAL_SUPPLY + MAX_LIQUIDITY_SUPPLY + MAX_STAKING_INTEREST_SUPPLY).mul(multiplier())
                                    <= IERC20(saleToken).balanceOf(address(this)), 'No more token available for Sale');
        }
        uint _amount = _numberOfUnits.mul(rate);
        IERC20(busdToken).transferFrom(msg.sender, wallet, _amount);
        IERC20(saleToken).transfer(msg.sender, _numberOfUnits);
    }

    function multiplier() internal view returns(uint) {
        return 10**IERC20(saleToken).decimals();
    }
}