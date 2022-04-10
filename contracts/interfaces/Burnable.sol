// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface Burnable {
    //function mint(uint _amount) external returns (bool);
    function burn(address _holder, uint _amount) external returns (bool);
}
