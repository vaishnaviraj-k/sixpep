//SPDX-License-Identifier: MIT 

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../contracts/testToken.sol";

contract DepositContract 
{
    ERC20 public BUSDToken;
    address tokenAddress;

    constructor () 
    {
        BUSDToken = ERC20(0x4fabb145d64652a948d72533023f6e7a623c7c53);
    }

    function deposit (uint256 value) public 
    {
        BUSDToken. transferFrom (msg.sender, address (this), value);
    }

    function getApproval ()

}
