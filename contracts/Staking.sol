// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import './interfaces/IERC20.sol';

import "./libraries/SafeMath.sol";
import './Ownable.sol';

contract Staking is Ownable {
    using SafeMath for uint;

    uint public constant MAX_STAKING_INTEREST_SUPPLY = 18000;
    uint public constant APY_PERCENT = 25000;

    struct StakedInfo {
        uint stakedAmount;
        uint stakedTimestamp;
        uint unstakedTimestamp;
        uint interestAmount;
        uint claimTimestamp;
    }

    // Interest Supply of Sale token
    uint public stakingInterestSupply;

    //Map of wallet address to array of StakedInfo of any user
    mapping(address => StakedInfo[]) internal stakedData;

    constructor() {
        stakingInterestSupply = MAX_STAKING_INTEREST_SUPPLY.mul(multiplier());
    }
    
    /**
     * @dev Function to stake or deposit sale token
     * @param _numberOfUnits Number of SLDRs in smallest unit to be staked
     */
    function stakeToken(address staker, uint _numberOfUnits) external onlyOwner {
        require(_numberOfUnits > 0, 'Number of Units is Zero');
        StakedInfo memory currentStake = StakedInfo({
            stakedAmount: _numberOfUnits,
            stakedTimestamp: block.timestamp,
            unstakedTimestamp: 0,
            interestAmount: 0,
            claimTimestamp: 0
        });
        stakedData[staker].push(currentStake);
    }
    /**
     * @dev Function to unstake or withdraw principal staked sale token
     */
    function unstakeToken(address staker) external onlyOwner returns(uint){
        uint _length = stakedData[staker].length;
        uint totalStakedAmount = 0;
        for(uint i=0; i< _length; i++) {
            if(stakedData[staker][i].unstakedTimestamp == 0) {
                totalStakedAmount += stakedData[staker][i].stakedAmount;
                stakedData[staker][i].unstakedTimestamp = block.timestamp;
            }
        }
        return totalStakedAmount;
    }
    /**
     * @dev Function to claim staked interest in sale token
     */
    function claimStakedInterest(address staker) external onlyOwner returns(uint) {
        uint _length = stakedData[staker].length;
        uint totalStakedInt = 0;
        uint eachStakedInt = 0;
        uint endTimeStamp = 0;
        for(uint i=0; i< _length; i++) {
            if(stakedData[staker][i].unstakedTimestamp > 0 && stakedData[staker][i].claimTimestamp >= stakedData[staker][i].unstakedTimestamp) {
                continue;
            }
            eachStakedInt = 0;
            if(stakedData[staker][i].unstakedTimestamp > 0) {
                endTimeStamp = stakedData[staker][i].unstakedTimestamp;
            } else {
                endTimeStamp = block.timestamp;
            }

            if(stakedData[staker][i].claimTimestamp == 0) {
                eachStakedInt = calculateInterestAmount(stakedData[staker][i].stakedAmount, stakedData[staker][i].stakedTimestamp, endTimeStamp);
            } else {
                eachStakedInt = calculateInterestAmount(stakedData[staker][i].stakedAmount, stakedData[staker][i].claimTimestamp, endTimeStamp);
            }

            if(stakedData[staker][i].unstakedTimestamp > 0 && // Unstake occured
                    stakedData[staker][i].claimTimestamp < stakedData[staker][i].unstakedTimestamp) { //But Not yet Claimed
                totalStakedInt += eachStakedInt; // Unstake occured
            } else if(stakedData[staker][i].unstakedTimestamp == 0) { //Still staked
                totalStakedInt += eachStakedInt;
            }
            stakedData[staker][i].claimTimestamp = block.timestamp;
            stakedData[staker][i].interestAmount += eachStakedInt;
        }
        if(totalStakedInt > stakingInterestSupply) {
            totalStakedInt = stakingInterestSupply;
        }
        if(totalStakedInt > 0) {
            stakingInterestSupply = stakingInterestSupply - totalStakedInt;
        }
        return totalStakedInt;
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
     * @dev Function to distribute swapped BUSD to recipients
     * @param _tokenAddress Address of BUSD token
     * @param _recipient Address of Recipient of adjusted amount
     * @param _taxRecipient Address of Recipient of tax amount
     * @param _adjustedValue Amount of tax deducted tokens
     * @param _taxAmount Amount of tax
     */
    function distributeSwappedToken(address _tokenAddress, address _recipient, address _taxRecipient, uint _adjustedValue, uint _taxAmount) external onlyOwner {
        IERC20(_tokenAddress).transfer(_recipient, _adjustedValue);
        IERC20(_tokenAddress).transfer(_taxRecipient, _taxAmount);
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

    function multiplier() internal pure returns(uint) {
        return 10**6;
    }
}