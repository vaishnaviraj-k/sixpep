// SPDX-License-Identifier: MIT

pragma solidity  >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../contracts/token.sol";

contract stakeable is ERC20, BallToken
{
    IERC20 public stakingToken;
    IERC20 public rewardsToken;

    struct userInfo 
    {
        uint256 stakes;
        uint256 startTime;
    }

    address [] stakeholders;
    uint256 totalRewards;
    uint256 mintCapacity;
    uint256 lastMinted;
    uint256 totalStake;

    mapping(address => userInfo) user;
    mapping(address => uint256) rewards;

    event Stake(address indexed user, uint256 amount);
    event Unstake(address indexed user, uint256 amount);
    event ClaimReward(address indexed user, uint256 reward);

    constructor (address _stakingToken) 
    {
        require (_stakingToken != address(0));
        stakingToken = IERC20(_stakingToken);
        lastMinted = block.timestamp;
        totalRewards = 40000 * 10 ** 18;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) 
    {
            require(b > 0);
            return a / b;
    }

    function stakeOf () public view returns(uint256)
   {
       return user[msg.sender].stakes;
   }

   function rewardOf(address stakeholder) public view returns (uint256)
   {
       return rewards[stakeholder];
   }   

   function contractBalance () public view returns (uint256) 
   {
       return stakingToken.balanceOf(address(this));
   }

    function addStake (IERC20 token, uint256 value) public returns (uint256)
   {
       require (token == stakingToken, "Only the tokens with the address mentioned in the constructor can be staked.");
       require (stakingToken.balanceOf(msg.sender) >= 0, "Cannot stake zero.");
       require (value <= stakingToken.balanceOf(msg.sender), "Insufficient funds.");

       stakingToken.transferFrom(msg.sender, address(this), value);
       user[msg.sender].startTime = block.timestamp;
       if(user[msg.sender].stakes == 0) addStakeholder(msg.sender);
       user[msg.sender].stakes += value;
       totalStake += value;

       emit Stake (msg.sender, value);

       return totalStake;
    }

   function removeStake(uint256 value) public returns (uint256)
   {
       require (value <= user[msg.sender].stakes, "Insufficient funds.");
       user[msg.sender].stakes -= value;
       if(user[msg.sender].stakes == 0) removeStakeholder(msg.sender);
       stakingToken.transferFrom (address(this), msg.sender, value);
       totalStake -= value;

       emit Unstake(msg.sender, value);

       return totalStake;
   }

    function claimRewards(uint256 value) public
    {
        uint256 reward = calculateRewards (msg.sender);
        rewards[msg.sender] = reward;

        require (rewards[msg.sender] > 0, "Amount should be greater than zero.");
        require (rewards[msg.sender] >= value, "Insufficient funds.");
        require (reward <= mintCapacity);

        mint (address(this), reward + mintCapacity);
        stakingToken.transferFrom (address(this), msg.sender, rewards[msg.sender]);
        rewards[msg.sender] -= value;

        emit ClaimReward(msg.sender, reward);
    }

    function calculateRewards (address addr) public view returns (uint256)
   {
      uint256 time;

      time = div (block.timestamp - user[addr].startTime, 86400);

      uint256 rewardEachDay = div (totalRewards, 365);
      uint256 rewardForEach = rewardEachDay * div(user[addr].stakes, totalStake);
      uint256 rewardWithTime = rewardForEach * time;
      return rewardWithTime;
   } 

    function isStakeholder(address _address) public view returns(bool, uint256)
    {
        for (uint256 i = 0; i < stakeholders.length; i++)
        {
            if (_address == stakeholders[i]) 
            {
                return (true, i);
            }
        }
        return (false, 0);
    }

    function addStakeholder(address stakeholder) public
    {
        (bool _isStakeholder, ) = isStakeholder (stakeholder);
        if (!_isStakeholder) stakeholders.push (stakeholder);
    }

    function removeStakeholder(address _stakeholder) public
   {
       (bool _isStakeholder, uint256 i) = isStakeholder(_stakeholder);
       if(_isStakeholder)
       {
           stakeholders[i] = stakeholders[stakeholders.length - 1];
           stakeholders.pop();
       }
   }

   function getmintingCapacity () public returns (uint256)
   {
       uint256 dailyMintCapacity; // = value;
       mintCapacity += dailyMintCapacity * div (block.timestamp - lastMinted, 86400);
       return mintCapacity;
   }
}
