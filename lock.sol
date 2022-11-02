// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Staking 
{
    using SafeERC20 for IERC20;

    uint256 public initialTime;
    uint256 public timePeriod;
    IERC20 public tokenContract;

    mapping (address => uint256) locked;

    event tokensLocked(address from, uint256 amount);
    event TokensUnlocked(address to, uint256 amount);

    constructor(IERC20 tokenContractAddress) 
    {
        require(address(tokenContractAddress) != address(0), "tokenContractAddress address can not be zero.");
        tokenContract = tokenContractAddress
    }

    function lockTokens (IERC20 token, uint256 value) public 
    {
        require(token == tokenContract, "Only tokens of address mentioned in the constructor can be staked.");
        require(value <= token.balanceOf(msg.sender), "Insufficient funds.");

        token.safeTransferFrom (msg.sender, address(this), value);
        stakes[msg.sender] += value;

        emit tokensStaked(msg.sender, value);
    }

    function setTime (uint256 time) public  
    {
        initialTimestamp = block.timestamp;
        timePeriod = initialTimestamp + time;
    }

    function unlockTokens(IERC20 token, uint256 value) public
    {
        require(locked[msg.sender] >= value, "Insufficient funds.");
        require(token == tokenContractAddress);
        if (block.timestamp >= timePeriod) 
        {
            locked[msg.sender] -= value;
            token.safeTransfer(msg.sender, amount);
            emit TokensUnstaked(msg.sender, amount);
        } 
        else 
        {
            revert("Tokens still locked.");
        }
    }

    

}
