// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import './interfaces/IERC20.sol';
import './interfaces/Mintable.sol';
import './interfaces/IPancakeRouter02.sol';
import './interfaces/IPancakeFactory.sol';
import "./libraries/SafeMath.sol";
import './tokens/PausableToken.sol';
import './Stake.sol';
import './Ownable.sol';

contract Crowdsale is Ownable {
    using SafeMath for uint;

    // Crowdsale Stages
    enum CrowdsaleStage { SALE_NOTSTARTED, PRESALE_STAGE1, PRESALE_STAGE2, PRESALE_STAGE3, SALE }

    // Default to presale stage
    CrowdsaleStage internal stage = CrowdsaleStage.PRESALE_STAGE1;

    uint public constant MAX_STAKING_INTEREST_SUPPLY = 18000;
    uint public constant MAX_REFERRAL_SUPPLY = 2000;
    uint public constant MAX_LIQUIDITY_SUPPLY = 5000;
    uint public constant MAX_PRESALE_SLOT1_SUPPLY = 5000;
    uint public constant MAX_PRESALE_SLOT2_SUPPLY = 20000;
    uint public constant MAX_PRESALE_SLOT3_SUPPLY = 30000;
    uint public constant APY_PERCENT = 25000;

    struct StakedInfo {
        uint stakedAmount;
        uint stakedTimestamp;
        uint unstakedTimestamp;
        uint interestAmount;
        uint claimTimestamp;
    }

    IPancakeRouter02 public pancakeRrouter;
    address public pancakeswapV2Pair;

    // The presale token
    address public busdToken;
    // The presale token
    address public presaleToken;
    // The sale token
    address public saleToken;
    // The P2 token
    address public p2Token;
    // Address where funds are collected
    address public wallet;
    // Address of Staking contract
    Stake public stakeContract;
    // Interest Supply of Sale token
    uint public stakingInterestSupply;
    // Referral Supply of Sale token
    uint public referralSupply;
    
    // How many token units a buyer gets per BUSD in wei
    uint public preSaleSlot1rate = 10000000000000;
    uint public presaleSlot1StartTime;
    uint public presaleSlot1EndTime;

    uint public preSaleSlot2rate = 15000000000000;
    uint public presaleSlot2StartTime;
    uint public presaleSlot2EndTime;

    uint public preSaleSlot3rate = 20000000000000;
    uint public presaleSlot3StartTime;
    uint public presaleSlot3EndTime;

    uint public saleStartTime;

    uint public redemptionStartTime;
    uint public redemptionEndTime;
    //Map of wallet address to array of StakedInfo of any user
    mapping(address => StakedInfo[]) internal stakedData;

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
        stakeContract = new Stake(_saleToken);
        wallet = _wallet;
        stakingInterestSupply = MAX_STAKING_INTEREST_SUPPLY.mul(multiplier());
        referralSupply = MAX_REFERRAL_SUPPLY.mul(multiplier());

        presaleSlot1StartTime = _saleStartTime - (21 * 24 * 60 * 60);
        presaleSlot1EndTime = presaleSlot1StartTime + (7 * 24 * 60 * 60);
        presaleSlot2StartTime = _saleStartTime - (14 * 24 * 60 * 60);
        presaleSlot2EndTime = presaleSlot2StartTime + (7 * 24 * 60 * 60);
        presaleSlot3StartTime = _saleStartTime - (7 * 24 * 60 * 60);
        presaleSlot3EndTime = presaleSlot3StartTime + (7 * 24 * 60 * 60);
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
        uint _rate;
        uint _soldTokens = IERC20(presaleToken).totalSupply() - IERC20(presaleToken).balanceOf(address(this));
        if(block.timestamp < presaleSlot1EndTime) {
            _rate = preSaleSlot1rate;
            require(_soldTokens + _numberOfUnits <= MAX_PRESALE_SLOT1_SUPPLY.mul(multiplier()), 'Presale Slot1 limit crossed');
        } else if(block.timestamp >= presaleSlot2StartTime && block.timestamp < presaleSlot2EndTime) {
            _rate = preSaleSlot2rate;
            require(_soldTokens + _numberOfUnits <= 
                    (MAX_PRESALE_SLOT1_SUPPLY + MAX_PRESALE_SLOT2_SUPPLY).mul(multiplier()), 'Presale Slot2 limit crossed');
        } else if(block.timestamp >= presaleSlot3StartTime && block.timestamp < presaleSlot3EndTime) {
            _rate = preSaleSlot3rate;
            require(_soldTokens + _numberOfUnits <= 
                    (MAX_PRESALE_SLOT1_SUPPLY + MAX_PRESALE_SLOT2_SUPPLY + MAX_PRESALE_SLOT3_SUPPLY).mul(multiplier()), 'Presale Slot3 limit crossed');
        }
        uint _amount = _numberOfUnits.mul(_rate);
        IERC20(busdToken).transferFrom(msg.sender, wallet, _amount);
        IERC20(presaleToken).transfer(msg.sender, _numberOfUnits);
    }
    /**
     * @dev Function to sell sale token in wei
     * @param _numberOfUnits Number of SLDRS in smallest unit to buy
     */
    function sell(uint _numberOfUnits) external {
        require(block.timestamp >= saleStartTime, 'Sell not allowed');
        if(block.timestamp < saleStartTime + (2 * 24 * 60 * 60)) { //75% tax on sale

        } else if(block.timestamp >= saleStartTime + (2 * 24 * 60 * 60) && block.timestamp < saleStartTime + (3 * 24 * 60 * 60)) { // 4% tax on sale

        } else if(block.timestamp >= saleStartTime + (3 * 24 * 60 * 60)) { // Exchange with P2 token
            Mintable(saleToken).burn(msg.sender, _numberOfUnits);
            IERC20(p2Token).transfer(msg.sender, _numberOfUnits);
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
     * @dev Function to stake or deposit sale token
     * @param _numberOfUnits Number of SLDRs in smallest unit to be staked
     */
    function stakeToken(uint _numberOfUnits) external {
        require(_numberOfUnits > 0, 'Number of Units is Zero');
        IERC20(saleToken).transferFrom(msg.sender, address(stakeContract), _numberOfUnits);
        StakedInfo memory currentStake = StakedInfo({
            stakedAmount: _numberOfUnits,
            stakedTimestamp: block.timestamp,
            unstakedTimestamp: 0,
            interestAmount: 0,
            claimTimestamp: 0
        });
        stakedData[msg.sender].push(currentStake);
    }
    /**
     * @dev Function to unstake or withdraw principal staked sale token
     */
    function unstakeToken() external {
        uint _length = stakedData[msg.sender].length;
        uint totalStakedAmount = 0;
        for(uint i=0; i< _length; i++) {
            if(stakedData[msg.sender][i].unstakedTimestamp == 0) {
                totalStakedAmount += stakedData[msg.sender][i].stakedAmount;
                stakedData[msg.sender][i].unstakedTimestamp = block.timestamp;
            }
        }
        if(totalStakedAmount > 0) {
            stakeContract.unstakeToken(msg.sender, totalStakedAmount);
        }
    }
    /**
     * @dev Function to claim staked interest in sale token
     */
    function claimStakedInterest() external {
        uint _length = stakedData[msg.sender].length;
        uint totalStakedInt = 0;
        uint eachStakedInt = 0;
        uint endTimeStamp = 0;
        for(uint i=0; i< _length; i++) {
            if(stakedData[msg.sender][i].unstakedTimestamp > 0 && stakedData[msg.sender][i].claimTimestamp >= stakedData[msg.sender][i].unstakedTimestamp) {
                continue;
            }
            eachStakedInt = 0;
            if(stakedData[msg.sender][i].unstakedTimestamp > 0) {
                endTimeStamp = stakedData[msg.sender][i].unstakedTimestamp;
            } else {
                endTimeStamp = block.timestamp;
            }

            if(stakedData[msg.sender][i].claimTimestamp == 0) {
                eachStakedInt = calculateInterestAmount(stakedData[msg.sender][i].stakedAmount, stakedData[msg.sender][i].stakedTimestamp, endTimeStamp);
            } else {
                eachStakedInt = calculateInterestAmount(stakedData[msg.sender][i].stakedAmount, stakedData[msg.sender][i].claimTimestamp, endTimeStamp);
            }

            if(stakedData[msg.sender][i].unstakedTimestamp > 0 && // Unstake occured
                    stakedData[msg.sender][i].claimTimestamp < stakedData[msg.sender][i].unstakedTimestamp) { //But Not yet Claimed
                totalStakedInt += eachStakedInt; // Unstake occured
            } else if(stakedData[msg.sender][i].unstakedTimestamp == 0) { //Still staked
                totalStakedInt += eachStakedInt;
            }
            stakedData[msg.sender][i].claimTimestamp = block.timestamp;
            stakedData[msg.sender][i].interestAmount += eachStakedInt;
        }
        if(totalStakedInt > stakingInterestSupply) {
            totalStakedInt = stakingInterestSupply;
        }
        if(totalStakedInt > 0) {
            stakingInterestSupply = stakingInterestSupply - totalStakedInt;
            Mintable(saleToken).burn(address(this), totalStakedInt.mul(5).div(100));
            IERC20(saleToken).transfer(msg.sender, totalStakedInt.mul(95).div(100));
        }
    }
    /**
     * @dev Function to get staked info for an address
     * @param _wallet Wallet address for which query for staking info being made
     */
    function getStakedData(address _wallet) external view returns(StakedInfo[] memory) {
        uint _length = stakedData[_wallet].length;
        StakedInfo[] memory _stakedData = new StakedInfo[](_length);
        for(uint i=0; i< _length; i++) {
            _stakedData[i] = stakedData[_wallet][i];
        }
        return _stakedData;
    }
    /**
     * @dev Function to send referral token to a given address
     * @param _to Wallet address to whome referral is sent
     * @param _amount Amount of Soldiers token to be given as referral
     */
    function referral(address _to, uint _amount) external onlyOwner {
        require(_amount <= referralSupply, 'Max Referral amount exhausted');
        referralSupply -= _amount;
        IERC20(saleToken).transfer(_to, _amount);
    }
    /**
     * @dev Function to to update Pancake Swap router
     * @param newAddress new address of Pancake Swap V2 router
     */
    function updatePancakeswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(pancakeRrouter), "Rematix: The router already has that address");
        pancakeRrouter = IPancakeRouter02(newAddress);
        address _pancakeswapV2Pair = IPancakeFactory(pancakeRrouter.factory())
            .createPair(address(saleToken), address(busdToken));
        pancakeswapV2Pair = _pancakeswapV2Pair;
    }
    /**
     * @dev Function to calculate APY interest
     * @param _stakedAmount Principal amount
     * @param _startTimestamp Start timestamp
     * @param _endTimestamp End timestamp
     */
    function calculateInterestAmount(uint _stakedAmount, uint _startTimestamp, uint _endTimestamp) public pure returns(uint) {
        require(_endTimestamp >=  _startTimestamp, 'End time should be after start');
        uint timeDiffinSecs = _endTimestamp - _startTimestamp;
        return _stakedAmount.mul(APY_PERCENT).div(100).mul(timeDiffinSecs).div(365 * 24 * 3600); // amount * (25000/100) * (diffOfSecs / 365 * 24 * 3600)
    }
    /**
     * @dev Function returns stage of sale at any point in time
     */
    function getStageOfSale() external view returns(CrowdsaleStage) {
        if(block.timestamp < presaleSlot1StartTime) {
            return CrowdsaleStage.SALE_NOTSTARTED;
        } else if(block.timestamp >= presaleSlot1StartTime && block.timestamp < presaleSlot1EndTime) {
            return CrowdsaleStage.PRESALE_STAGE1;
        } else if(block.timestamp >= presaleSlot2StartTime && block.timestamp < presaleSlot2EndTime) {
            return CrowdsaleStage.PRESALE_STAGE2;
        } else if(block.timestamp >= presaleSlot3StartTime && block.timestamp < presaleSlot3EndTime) {
            return CrowdsaleStage.PRESALE_STAGE3;
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
        require(presaleSlot1EndTime <= presaleSlot2StartTime, 'Presale Slot1 end time greater than slot2 start time');
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
        require(presaleSlot2EndTime <= presaleSlot3StartTime, 'Presale slot2 end time greater than slot3 start time');
    }
    /**
     * @dev Function to set public presale or slot3 rate in BUSD in wei
     * @param _rate Amount of BUSD in wei per small unit to buy
     */
    function setPreSaleSlot3Rate(uint _rate) public onlyOwner {
        require(_rate > 0, 'Presale Slot2 Rate is 0');
        preSaleSlot3rate = _rate;
    }
    /**
     * @dev Function to set pre-sale slot3 window w.r.t sale start time
     * @param _daysPrior number of days prior to sale start time
     * @param _durationInSecs duration of presale in seconds or epoch from slot3 start time
     */
    function setPreSaleSlot3Window(uint _daysPrior, uint _durationInSecs) public onlyOwner {
        presaleSlot3StartTime = saleStartTime - (_daysPrior * 24 * 60 * 60);
        presaleSlot3EndTime = presaleSlot3StartTime + _durationInSecs;
        require(presaleSlot3EndTime <= saleStartTime, 'Presale Slot3 end time greater than sale time');
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

    function multiplier() internal view returns(uint) {
        return 10**IERC20(saleToken).decimals();
    }


}