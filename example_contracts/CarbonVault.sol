// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract CarbonVault is Ownable {

    using Counters for Counters.Counter;

    Counters.Counter private _boxId;

    mapping(address => bool) public allowedCaller;
    mapping(address => mapping(uint => CarbonBox)) public carbonBoxes;
   
    
    struct CarbonBox {
        uint256 startDate;
        uint256 endDate;
        uint256 amount;
        uint256 startPrice;
        uint256 endPrice;
        address owner;
        address carbonAddr;
    }

    modifier onlyAllowedCallers {
        require(allowedCaller[msg.sender] == true, "Not allowed");
        _;
    }

    function lockCarbon(uint256 endDate, uint256 amount, uint256 startPrice, uint256 endPrice, address owner, address carbonAddr) external onlyAllowedCallers {
        ERC20(carbonAddr).transferFrom(msg.sender, address(this), amount);
        carbonBoxes[owner][_boxId.current()] = (CarbonBox(block.timestamp, endDate, amount, startPrice, endPrice, owner, carbonAddr));
        _boxId.increment();
    }

    function claimCarbon(uint16 index) external {
        CarbonBox memory carbonBox = carbonBoxes[msg.sender][index];
        require(carbonBox.endDate >= block.timestamp, "Still locked !");
        ERC20(carbonBox.carbonAddr).transfer(msg.sender, carbonBox.amount);
    }

    function allowCaller(address caller) external onlyOwner {
        allowedCaller[caller] = true;
    }
}