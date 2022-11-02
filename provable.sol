//SPDX-License-Identifier: undefined

pragma solidity ^0.8.0;

import "https://github.com/provable-things/ethereum-api/blob/master/contracts/solc-v0.8.x/provableAPI.sol";

contract ExampleContract is usingProvable 
{

    struct Details 
    {
        string symbol;
        string currency;
        string bid;
        string ask;
        string last;
        string open;
        string close;
        string low;
        string high;
        string volume;
        string volume_traded;
    }

    Details public ETHUSD;

    event LogConstructorInitiated(string nextStep);
    event LogPriceUpdated(string [] result);
    event LogNewProvableQuery(string description);

    function example () payable public 
    {
        emit LogConstructorInitiated("Constructor was initiated. Call 'updatePrice()' to send the Provable Query.");
    }
    
    function __callback(bytes32 _id, string [] memory result) public 
    {
        if (msg.sender != provable_cbAddress()) revert();
        ETHUSD.symbol = result[0];
        ETHUSD.currency = result[1];
        emit LogPriceUpdated (result);
    }

   function updatePrice() payable public 
   {
       if (provable_getPrice("URL") > address(this).balance) 
       {
           emit LogNewProvableQuery("Provable query was NOT sent, please add some ETH to cover for the query fee");
       } else 
       {
           emit LogNewProvableQuery("Provable query was sent, standing by for the answer..");
           provable_query("URL", "json(https://www.therocktrading.com/api/ticker/BTCEUR).result.0.*");
       }
   }
}
