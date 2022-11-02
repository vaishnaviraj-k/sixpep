// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Staking 
{
    uint256 public initialTime;
    uint256 public timePeriod;
    IERC20 public token;

    mapping (address => uint256) locked;

    event tokensLocked(address from, uint256 amount);
    event tokensUnlocked(address to, uint256 amount);

    constructor(address tokenContractAddress) 
    {
        require(address(tokenContractAddress) != address(0), "tokenContractAddress address can not be zero.");
        token = IERC20(tokenContractAddress);
    }

    function lockTokens (IERC20 tokenContract, uint256 value) public 
    {
        require(token == tokenContract, "Only tokens of address mentioned in the constructor can be staked.");
        require(value <= token.balanceOf(msg.sender), "Insufficient funds.");

        token.transferFrom (msg.sender, address(this), value);
        locked[msg.sender] += value;

        emit tokensLocked(msg.sender, value);
    }

    function setTime (uint256 time) public  
    {
        initialTime = block.timestamp;
        timePeriod = initialTime + time;
    }

    function unlockTokens(IERC20 tokenContract, uint256 value) public
    {
        require(locked[msg.sender] >= value, "Insufficient funds.");
        require(token == tokenContract);
        if (block.timestamp >= timePeriod) 
        {
            locked[msg.sender] -= value;
            token.transferFrom(address(this), msg.sender, value);

            emit tokensUnlocked(msg.sender, value);
        } 
        else 
        {
            revert("Tokens still locked.");
        }
    }

    

}
