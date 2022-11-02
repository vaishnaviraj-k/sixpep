// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "../contracts/token.sol";

contract Rewards is BallToken
{
    struct rewardInfo 
    {
        address account;
        uint256 value;
    }

    uint256 startTime;
    uint256 releaseTime;
    uint256 totalRewardsSupply;
    uint256 dailyMintingCapacity;


    mapping (address => uint256) rewards;

    IERC20 public token;

    constructor (uint256 _releaseTime, address _tokenAddress, uint256 _totalRewardsSupply) 
    {
        startTime = block.timestamp;
        releaseTime = _releaseTime;
        token = IERC20(_tokenAddress);
        totalRewardsSupply = _totalRewardsSupply;
    }

    function getRewards () public view returns (uint256) 
    {
        return rewards[msg.sender];
    }
    
    function setReward (address account, uint256 value) public onlyOwner
    {
        rewards[account] += value;
    }

    function setRewards (rewardInfo [] calldata info) public 
    {
        for (uint256 i = 0; i < info.length; i++) 
        {
            require (info[i].value <= totalRewardsSupply, "Cannot assign value exceeding total rewards supply.");
            require (info[i].value <= dailyMintingCapacity * (startTime - releaseTime),
            "Cannot set rewards greater than claimable at the release time.");
            setReward (info[i].account, info[i].value);
        }
    }

    function claimReward (uint256 value) public 
    {
        require (value <= rewards[msg.sender], "Insufficient funds.");
        require (block.timestamp >= releaseTime, "Locking period not expired.");
        mint (msg.sender, value);
        rewards[msg.sender] -= value;
    }
}
