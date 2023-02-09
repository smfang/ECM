// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ProjectNFT.sol";
import "./CarbonVault.sol";
import "./CarbonToken.sol";

contract MinimalProjectFactory is Ownable{

    address public vault;
    address public carbonToken;

    function setVault(address _vault) external onlyOwner {
        vault = _vault;
    }

    function setCarbonToken(address _token) external onlyOwner {
        carbonToken = _token;
    }

    function createProject(
            address projectNFTPreset, 
            address buyer, 
            uint256 carbonAmount, 
            string calldata name, 
            string calldata symbol
        ) external onlyOwner returns (address) {

        address clone = Clones.clone(projectNFTPreset);
        ProjectNFT(clone).initialize(name, symbol);
        ProjectNFT(clone).safeMint(buyer);

        CarbonToken(carbonToken).approve(vault, carbonAmount);
        Vault(vault).lockCarbon(block.timestamp + 1 minutes, carbonAmount, 1000, 10000, buyer, carbonToken);
        return clone;
    }

     function updateProject(address projectAddrr, address projectNFTAddr, address buyer, uint256 amount) external onlyOwner {
        ProjectNFT(projectAddrr).safeMint(buyer);
        CarbonToken(projectNFTAddr).mint(buyer, amount); 
    }
}