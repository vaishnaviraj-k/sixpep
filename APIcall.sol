// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import '@chainlink/contracts/src/v0.8/ChainlinkClient.sol';
import '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';

contract APIConsumer is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    uint256 public price;
    uint256 public volume;
    bytes32 private jobId;
    uint256 private fee;

    struct Data 
    {
        uint256 Price;
        uint256 Volume;
    }

    event RequestPrice(bytes32 indexed requestId, uint256 price);
    event RequestVolume(bytes32 indexed requestId, uint256 volume);

    constructor() ConfirmedOwner(msg.sender) {
        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
        setChainlinkOracle(0xCC79157eb46F5624204f47AB42b3906cAA40eaB7);
        jobId = 'ca98366cc7314957b8c012c72f05aeeb';
        fee = (1 * LINK_DIVISIBILITY) / 10; 
    }

    function requestPriceData() public returns (bytes32 requestId) 
    {
        Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfillPrice.selector);

        req.add('get', 'https://api.pro.coinbase.com/products/ETH-USD/ticker');
        req.add('path', 'price');

        int256 timesAmount = 10**3;
        req.addInt('times', timesAmount);

        return sendChainlinkRequest(req, fee);
    }

    function requestVolumeData () public returns (bytes32 requestID) 
    {
        Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfillVolume.selector);

        req.add('get', 'https://api.pro.coinbase.com/products/ETH-USD/ticker');
        req.add('path', 'volume');

        int256 timesAmount = 10**8;
        req.addInt('times', timesAmount);

        return sendChainlinkRequest(req, fee);
    } 

    function fulfillPrice(bytes32 _requestId, uint256 _price) public recordChainlinkFulfillment(_requestId) 
    {
        emit RequestPrice(_requestId, _price);
        price = _price;
    }

    function fulfillVolume(bytes32 _requestId, uint256 _volume) public recordChainlinkFulfillment(_requestId) 
    {
        emit RequestPrice(_requestId, _volume);
        volume = _volume;
    }

    function getData () public 
    {
        requestPriceData();
        requestVolumeData();
    }

    function returnData () public view returns (uint256 _price, uint256 _volume) {
        Data memory data = Data ({
            Price : price,
            Volume : volume
        });

        return (data.Price, data.Volume);
    }


    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.transfer(msg.sender, link.balanceOf(address(this))), 'Unable to transfer');
    }
}
