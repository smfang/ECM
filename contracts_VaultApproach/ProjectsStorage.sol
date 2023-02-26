// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

contract ProjectsStorage {

    struct CarbonProjectStruct {
        string projectName;
        address projectAddress;
        address carbonToken;
    }

    mapping(address => CarbonProjectStruct) public deployedProjects;

}