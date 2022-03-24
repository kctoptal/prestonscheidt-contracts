// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import '../interfaces/IERC20.sol';
import "../libraries/SafeMath.sol";

abstract contract BasicToken is IERC20 {
    using SafeMath for uint;

    uint constant MAX = ~uint256(0);

    uint public override totalSupply;
    mapping(address => uint) public override balanceOf;
    mapping(address => mapping(address => uint)) public override allowance;
   
   /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
    function approve(address _spender, uint _value) public override virtual returns (bool) {
        require(_spender != address(0), "Approve to the invalid or zero address");
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

   /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint _value) public override virtual returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

   /**
    * The transferFrom method is used for a withdraw workflow, allowing contracts to transfer tokens on your behalf. 
    * This can be used for example to allow a contract to transfer tokens on your behalf and/or to charge fees in sub-currencies. 
    * The function SHOULD throw unless the _from account has deliberately authorized the sender of the message via some mechanism.
    * @param _from address which you want to send tokens from
    * @param _to address which you want to transfer to
    * @param _value uint the amount of tokens to be transferred
    */
    function transferFrom(address _from, address _to, uint _value) public override virtual returns (bool success) {
        require(_from != address(0), "Invalid Sender Address");
        require(allowance[_from][_to] >= _value, "Transfer amount exceeds allowance");
        _transfer(_from, _to, _value);
        allowance[_from][_to] = allowance[_from][_to].sub(_value);
        return true;
    }

   /**
    * Internal method that does transfer token from one account to another
    */
    function _transfer(address _sender, address _recipient, uint _amount) internal {
        require(_sender != address(0), "Invalid Sender Address");
        require(_recipient != address(0), "Invalid Recipient Address");
        
        uint balanceAmt = balanceOf[_sender];
        require(balanceAmt >= _amount, "Transfer amount exceeds balance of sender");
        require(_amount <= MAX - balanceOf[_recipient], "Balance limit exceeded for Recipient.");
        
        balanceOf[_sender] = balanceAmt.sub(_amount);
        balanceOf[_recipient] = balanceOf[_recipient].add(_amount);
        
        emit Transfer(_sender, _recipient, _amount);
    }

    /**
    * @dev Function to mint tokens
    * @param _to The address that will receive the minted tokens.
    * @param _amount The amount of tokens to mint.
    * @return A boolean that indicates if the operation was successful.
    */
    function _mint(address _to, uint _amount) internal returns (bool) {
        require(_to != address(0), "mint to the zero address");
        totalSupply = totalSupply.add(_amount);
        balanceOf[_to] = balanceOf[_to].add(_amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    /**
    * @dev Burns a specific amount of tokens.
    * @param _holder The address from which tokens to be burned.
    * @param _value The amount of token to be burned.
    */
    function _burn(address _holder, uint _value) internal returns (bool) {
        require(_holder != address(0), "Burn from the zero address");
        require(_value <= balanceOf[_holder], 'Burn amount exceeds balance of holder');

        balanceOf[_holder] = balanceOf[_holder].sub(_value);
        require(_value <= totalSupply, "Insufficient total supply.");
        totalSupply = totalSupply.sub(_value);
        emit Transfer(_holder, address(0), _value);
        return true;
    }
}