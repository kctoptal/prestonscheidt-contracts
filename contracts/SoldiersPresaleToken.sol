// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import './tokens/PausableToken.sol';

contract SoldiersPresaleToken is PausableToken {

    string public constant override name = 'Pre-Sale SOLDIERS Token';
    string public constant override symbol = '$pSLDRS';
    uint8 public constant override decimals = 6;

    constructor(uint256 _initialSupply) {
        _mint(msg.sender, _initialSupply);
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
}