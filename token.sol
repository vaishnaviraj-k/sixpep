// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../contracts/mint.sol";

contract BallToken is ERC20, mintable 
{
    uint256 totalCapital;
    address owner;
    uint256 t_percent;
    uint256 fee;
    uint256 supply;
    address transactionContract;

    constructor () ERC20 ("BALL Token", "BALL")  
    {
        totalCapital = 100000000 * 10 ** 18; 
        _mint (msg.sender, 1000 * 10 ** 18);
        owner = msg.sender;
    }

    function setTransactionContract (address _transactionContract) public onlyOwner
    {
        transactionContract = _transactionContract;
    }

    function setTpercent (uint256 percent) public 
    {
        t_percent = percent;
    }

    function mint (address to, uint256 value) public onlyMintableAddress
    {
        require (value <= totalCapital && supply + value <= totalCapital);
        _mint (to, value);
        supply += value;
    }

    function TransferFrom (address from, address to, uint256 value) public 
    {
        fee = t_percent * value;
        uint256 amount = value - fee;
        transferFrom (from, to, amount);
        transferFrom (address(this), transactionContract , fee);
    }
}
