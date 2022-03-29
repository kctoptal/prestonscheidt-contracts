// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import './interfaces/Mintable.sol';
import './tokens/PausableToken.sol';

contract SoldiersToken is PausableToken, Mintable {

    string public constant override name = 'SOLDIERS Token';
    string public constant override symbol = '$SLDRS';
    uint8 public constant override decimals = 6;
    uint public override initialSupply;

    constructor(uint256 _initialSupply) {
        initialSupply = _initialSupply;
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

    function mint(uint _amount) external onlyOwner override returns (bool) {
        return _mint(msg.sender, _amount);
    }

    function burn(address _holder, uint _value) external onlyOwner override returns (bool) {
        return _burn(_holder, _value);
    }
}