//SPDX-License-Identifier: unlicenced

pragma solidity ^0.8.0;

contract Oracle {
    struct Request 
    {
        uint256 id;
        string apiUrl;
        string attributeToFetch;
        string valueFetched;
        mapping(uint256 => string) answers;
        mapping(address => uint) quorum; 
        //oracles which will query the answer (1=oracle hasn't voted, 2=oracle has voted)
    }

    Request [] requests;
    uint256 currentId;
    uint256 minResponses;
    uint256 totalOracleCount = 3;

    event NewRequest (uint id, string apiUrl, string attributeToFetch);
    event UpdatedRequest (uint id, string  apiUrl, string attributeToFetch, string valurFetched);

    function createRequest (string memory _apiUrl, string memory _attributeToFetch) public {

        Request storage r = requests.push();
        r.id = currentId;
        r.apiUrl = _apiUrl;
        r.attributeToFetch = _attributeToFetch;

        r.quorum[address(0x6c2339b46F41a06f09CA0051ddAD54D1e582bA77)] = 1;
        r.quorum[address(0xb5346CF224c02186606e5f89EACC21eC25398077)] = 1;
        r.quorum[address(0xa2997F1CA363D11a0a35bB1Ac0Ff7849bc13e914)] = 1;

        emit NewRequest (currentId, _apiUrl, _attributeToFetch);
        currentId ++;
    }

    function requestUpdate (uint256 _id, string memory _valueRetrieved) public {
        Request storage currentRequest = requests[_id];
        if (currentRequest.quorum[address(msg.sender)] == 1) 
        {
            currentRequest.quorum[msg.sender] = 2;
        }

        uint256 temp = 0;
        bool found = false;
        while(!found) {
            if(bytes(currentRequest.answers[temp]).length == 0) {
                found = true;
                currentRequest.answers[temp] = _valueRetrieved;
            }

            temp ++;
        }

        uint256 currentQuorum = 0;

        for (uint256 i = 0; i< totalOracleCount; i++) {
            bytes memory a = bytes(currentRequest.answers[i]);
            bytes memory b = bytes(_valueRetrieved);

            if (keccak256(a) == keccak256(b)) {
                currentQuorum ++;

                if(currentQuorum >= minResponses) 
                {
                    currentRequest.valueFetched = _valueRetrieved;
                }

                emit UpdatedRequest (currentRequest.id, currentRequest.apiUrl, 
                currentRequest.attributeToFetch, currentRequest.valueFetched);
            }
        }
    }    
}
  
