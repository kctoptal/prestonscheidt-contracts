// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import './interfaces/Burnable.sol';
import './tokens/PausableToken.sol';

contract BarracksToken is PausableToken, Burnable {

    string public constant override name = 'Barracks Token';
    string public constant override symbol = 'P2';
    uint8 public constant override decimals = 6;

    constructor(uint256 _initialSupply) {
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

    function burn(address _holder, uint _value) external onlyOwner override returns (bool) {
        return _burn(_holder, _value);
    }
}