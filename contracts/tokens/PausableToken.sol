// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./BasicToken.sol";
import '../Ownable.sol';

abstract contract PausableToken is BasicToken, Ownable {

    event Pause();
    event Unpause();
    bool public paused = false;

    /**
    * @dev Modifier to make a function callable only when the contract is not paused.
    */
    modifier whenNotPaused() {
        require(!isPaused(), 'Token Paused');
        _;
    }

    /**
    * @dev Modifier to make a function callable only when the contract is paused.
    */
    modifier whenPaused() {
        require(isPaused(), 'Token Not Paused');
        _;
    }
    /**
     * @dev Returns true if the Token is paused.
     */
    function isPaused() public view returns (bool) {
        return paused;
    }
    /**
    * @dev called by the owner to pause, triggers stopped state
    */
    function pause() onlyOwner whenNotPaused external {
        paused = true;
        emit Pause();
    }

    /**
    * @dev called by the owner to unpause, returns to normal state
    */
    function unpause() onlyOwner whenPaused external {
        paused = false;
        emit Unpause();
    }

    function transfer(address _to, uint _value) public override virtual whenNotPaused returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) public override virtual whenNotPaused returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint _value) public override virtual whenNotPaused returns (bool) {
        return super.approve(_spender, _value);
    }

}