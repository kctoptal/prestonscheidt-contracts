// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import './interfaces/IERC20.sol';
import './Ownable.sol';

contract Stake is Ownable {
    
    // The sale token
    address public saleToken;

    constructor(address _saleToken) {
        saleToken = _saleToken;
    }

    function unstakeToken(address _to, uint unstakeAmount) public onlyOwner {
        require(unstakeAmount <= IERC20(saleToken).balanceOf(address(this)), 'Insufficient balance');
        IERC20(saleToken).transfer(_to, unstakeAmount);
    }

    function multiplier() internal view returns(uint) {
        return 10**IERC20(saleToken).decimals();
    }
}