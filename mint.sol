// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract mintable
{

    struct mintableAddresses 
    {
        address mintableAddress;
        string nameOfTheContract;
        uint256 mintingCapacityOfTheContract;
        uint256 mintedValue;
    }

    mintableAddresses [] addresses;
    address owner;

    modifier onlyMintableAddress 
    {
        for (uint256 i = 0; i < addresses.length; i++) 
        {
            require(msg.sender == addresses[i].mintableAddress || address(this) == addresses[i].mintableAddress);
        }
      _;
   }

   modifier onlyOwner 
   {
       require (msg.sender == owner, "Only owner of the contract can access.");
       _;
   }
   
    function isMintableAddress (address _address) public view returns (bool)
    {
        for (uint256 i = 0; i < addresses.length; i++)
        {
            if (_address == addresses[i].mintableAddress) 
            {
                return (true);
            }
        }
        return (false);
    }

    function createMintableAddresses (mintableAddresses [] calldata info) public onlyOwner
    {
        
        for (uint256 i = 0; i < info.length; i++) 
        {
            bool _isMintableAddress = isMintableAddress (info[i].mintableAddress);
            if (_isMintableAddress = true) 
            {
                mintableAddresses memory newContract = mintableAddresses({
                mintableAddress: info[i].mintableAddress,
                nameOfTheContract: info[i].nameOfTheContract,
                mintingCapacityOfTheContract: info[i].mintingCapacityOfTheContract,
                mintedValue: 0 });

                addresses.push(newContract);
            }

            else 
            {
                revert ("Address is already present.");
            }
        
        }     
    }

}
