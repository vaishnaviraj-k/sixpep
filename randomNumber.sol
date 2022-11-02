//"SPDX-License-Identifier: UNLICENSED"

pragma solidity ^0.8.0;
 
contract RandomNumber
{
    
    function generateRandomNumber() public view returns(uint)
    {
        uint genNumber = uint(keccak256(abi.encodePacked("1665367212", msg.sender)));
        uint randomNumber = genNumber % 6;
        
        return randomNumber;
   }
}
