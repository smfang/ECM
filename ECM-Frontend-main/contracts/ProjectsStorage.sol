// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

contract ProjectsStorage {

    struct CarbonProjectStruct {
        string projectName;
        address projectAddress;
        address carbonToken;
    }

    struct Transaction {
        address buyerAddress;
        address projectAddress;
        uint256 amountBought;
        uint256 agreedPrice;
        uint256 startDate;
        uint256 endDate;
        uint256 proofId; // id of NFT 
        bool isOptionTrade;
    }

    mapping(address => CarbonProjectStruct) public deployedProjects;
    mapping(address => mapping(uint256 => Transaction)) public transactions;
    mapping(address => uint256) public latestTransactionIndex;
}