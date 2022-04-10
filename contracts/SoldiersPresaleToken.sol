// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import './interfaces/Burnable.sol';
import "./libraries/SafeMath.sol";
import './tokens/PausableToken.sol';

contract SoldiersPresaleToken is PausableToken, Burnable {
    using SafeMath for uint;

    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);

    uint public constant MAX_LIQUIDITY_SUPPLY = 5000;
    uint public constant MAX_PRESALE_SLOT1_SUPPLY = 5000;
    uint public constant MAX_PRESALE_SLOT2_SUPPLY = 20000;
    uint public constant MAX_PRESALE_SLOT3_SUPPLY = 30000;

    string public constant override name = 'Pre-Sale SOLDIERS Token';
    string public constant override symbol = '$pSLDRS';
    uint8 public constant override decimals = 6;
    
    // Crowdsale Stages
    enum CrowdsaleStage { SALE_NOTSTARTED, PRESALE_STAGE1, PRESALE_STAGE2, PRESALE_STAGE3, SALE }

    // The busd token
    address public busdToken;
    // Address where BUSD funds are collected
    address public wallet;

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

    mapping(address => bool) public whitelist;

    constructor(
        uint256 _initialSupply,
        uint _saleStartTime,
        address _busdToken,
        address _wallet
    ) {
        require(keccak256(abi.encodePacked(IERC20(_busdToken).symbol())) == keccak256(abi.encodePacked("BUSD")));
        require(_wallet != address(0));

        busdToken = _busdToken;
        wallet = _wallet;
        saleStartTime = _saleStartTime;

        presaleSlot1StartTime = _saleStartTime - (21 * 24 * 60 * 60);
        presaleSlot1EndTime = presaleSlot1StartTime + (7 * 24 * 60 * 60);
        presaleSlot2StartTime = _saleStartTime - (14 * 24 * 60 * 60);
        presaleSlot2EndTime = presaleSlot2StartTime + (7 * 24 * 60 * 60);
        presaleSlot3StartTime = _saleStartTime - (7 * 24 * 60 * 60);
        presaleSlot3EndTime = presaleSlot3StartTime + (7 * 24 * 60 * 60);
        _mint(owner(), _initialSupply);
    }
    function approve(address _spender, uint256 _value) public override returns (bool) {
       return super.approve(_spender, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public override returns (bool) {
        return super.transfer(_to, _value);
    }

    function burn(address _holder, uint _value) public onlyOwner override returns (bool) {
        return _burn(_holder, _value);
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
        return CrowdsaleStage.SALE_NOTSTARTED;
    }
    /**
     * @dev Function to buy pre sale token in BUSD in wei
     * @param _numberOfUnits Number of pSLDRs in smallest unit to buy
     */
    function buy(uint _numberOfUnits) external {
        require(block.timestamp >= presaleSlot1StartTime, 'Presale Not started');
        require(_numberOfUnits > 0, 'Number of Units is Zero');
        uint _rate;
        uint _soldTokens = totalSupply - balanceOf[wallet];
        if(block.timestamp < presaleSlot1EndTime) {
            _rate = preSaleSlot1rate;
            require(_soldTokens + _numberOfUnits <= MAX_PRESALE_SLOT1_SUPPLY.mul(multiplier()), 'Presale Slot1 limit crossed');
        } else if(block.timestamp >= presaleSlot2StartTime && block.timestamp < presaleSlot2EndTime) {
            _rate = preSaleSlot2rate;
            require(whitelist[msg.sender], 'Not Whitelisted');
            require(_soldTokens + _numberOfUnits <= 
                    (MAX_PRESALE_SLOT1_SUPPLY + MAX_PRESALE_SLOT2_SUPPLY).mul(multiplier()), 'Presale Slot2 limit crossed');
        } else if(block.timestamp >= presaleSlot3StartTime && block.timestamp < presaleSlot3EndTime) {
            _rate = preSaleSlot3rate;
            require(_soldTokens + _numberOfUnits <= 
                    (MAX_PRESALE_SLOT1_SUPPLY + MAX_PRESALE_SLOT2_SUPPLY + MAX_PRESALE_SLOT3_SUPPLY).mul(multiplier()), 'Presale Slot3 limit crossed');
        }
        uint _amount = _numberOfUnits.mul(_rate);
        IERC20(busdToken).transferFrom(msg.sender, wallet, _amount);
        _transfer(wallet, msg.sender, _numberOfUnits);
    }
    /**
     * @dev Function to set sale start time
     * @param _saleStartTimestamp sale start time
     */
    function setSaleStartTime(uint _saleStartTimestamp) external onlyOwner {
        saleStartTime = _saleStartTimestamp;
    }
    /**
     * @dev Function to set pre sale slot1 rate in BUSD in wei
     * @param _rate Amount of BUSD in wei per small unit to buy
     */
    function setPreSaleSlot1Rate(uint _rate) external onlyOwner {
        require(_rate > 0, 'Presale Slot1 Rate is 0');
        preSaleSlot1rate = _rate;
    }
    /**
     * @dev Function to set pre-sale slot1 window w.r.t sale start time
     * @param _daysPrior number of days prior to sale start time
     * @param _durationInSecs duration of presale in seconds or epoch from slot1 start time
     */
    function setPreSaleSlot1Window(uint _daysPrior, uint _durationInSecs) external onlyOwner {
        presaleSlot1StartTime = saleStartTime - (_daysPrior * 24 * 60 * 60);
        presaleSlot1EndTime = presaleSlot1StartTime + _durationInSecs;
        require(presaleSlot1EndTime <= presaleSlot2StartTime, 'Presale Slot1 end time greater than slot2 start time');
    }
    /**
     * @dev Function to set pre sale slot1 rate in BUSD in wei
     * @param _rate Amount of BUSD in wei per small unit to buy
     */
    function setPreSaleSlot2Rate(uint _rate) external onlyOwner {
        require(_rate > 0, 'Presale Slot2 Rate is 0');
        preSaleSlot2rate = _rate;
    }
    /**
     * @dev Function to set pre-sale slot2 window w.r.t sale start time
     * @param _daysPrior number of days prior to sale start time
     * @param _durationInSecs duration of presale in seconds or epoch from slot1 start time
     */
    function setPreSaleSlot2Window(uint _daysPrior, uint _durationInSecs) external onlyOwner {
        presaleSlot2StartTime = saleStartTime - (_daysPrior * 24 * 60 * 60);
        presaleSlot2EndTime = presaleSlot2StartTime + _durationInSecs;
        require(presaleSlot2EndTime <= presaleSlot3StartTime, 'Presale slot2 end time greater than slot3 start time');
    }
    /**
     * @dev Function to set public presale or slot3 rate in BUSD in wei
     * @param _rate Amount of BUSD in wei per small unit to buy
     */
    function setPreSaleSlot3Rate(uint _rate) external onlyOwner {
        require(_rate > 0, 'Presale Slot2 Rate is 0');
        preSaleSlot3rate = _rate;
    }
    /**
     * @dev Function to set pre-sale slot3 window w.r.t sale start time
     * @param _daysPrior number of days prior to sale start time
     * @param _durationInSecs duration of presale in seconds or epoch from slot3 start time
     */
    function setPreSaleSlot3Window(uint _daysPrior, uint _durationInSecs) external onlyOwner {
        presaleSlot3StartTime = saleStartTime - (_daysPrior * 24 * 60 * 60);
        presaleSlot3EndTime = presaleSlot3StartTime + _durationInSecs;
        require(presaleSlot3EndTime <= saleStartTime, 'Presale Slot3 end time greater than sale time');
    }
    /**
     * @dev add an address to the whitelist
     * @param addr address
     * @return success if the address was added to the whitelist, false if the address was already in the whitelist
     */
    function addAddressToWhitelist(address addr) onlyOwner public returns(bool success) {
        require(!whitelist[addr], 'Address already whitelisted');
    
        whitelist[addr] = true;
        emit WhitelistedAddressAdded(addr);
        success = true;
    }
    /**
     * @dev add addresses to the whitelist
     * @param addrs addresses
     * @return success if at least one address was added to the whitelist,
     * false if all addresses were already in the whitelist
     */
    function addAddressesToWhitelist(address[] memory addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            addAddressToWhitelist(addrs[i]);
        }
        return true;
    }
    /**
     * @dev remove an address from the whitelist
     * @param addr address
     * @return success if the address was removed from the whitelist,
     * false if the address wasn't in the whitelist in the first place
     */
    function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {
        require(whitelist[addr], 'Address not whitelisted');
        whitelist[addr] = false;
        emit WhitelistedAddressRemoved(addr);
        success = true;
    }
    /**
     * @dev remove addresses from the whitelist
     * @param addrs addresses
     * @return success if at least one address was removed from the whitelist,
     * false if all addresses weren't in the whitelist in the first place
     */
    function removeAddressesFromWhitelist(address[] memory addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            removeAddressFromWhitelist(addrs[i]);
        }
        return true;
    }
    function multiplier() internal pure returns(uint) {
        return 10**decimals;
    }
}