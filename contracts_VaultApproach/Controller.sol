// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "./MinimalFactory.sol";
import "./CarbonProject.sol";
import "./CarbonCreditToken.sol";
import "./ProjectsStorage.sol";

contract Controller is Ownable, ProjectsStorage {

    MinimalFactory public minimalFactory;
    CarbonVault public carbonVault;

    constructor(address _minimalFactoryAddr, address _carbonVault) {
        minimalFactory = MinimalFactory(_minimalFactoryAddr);
        carbonVault = CarbonVault(_carbonVault);
    }

    function initializeNewProject(
        string calldata projectName, 
        string calldata projectSymbol,
        uint256 availableCredits
    ) external onlyOwner returns(address, address){
        (address projectAddr, address tokenAddr) = minimalFactory.createProjectAndToken();
        CarbonProject(projectAddr).initialize(projectName, projectSymbol, availableCredits);
        CarbonCreditToken(tokenAddr).initialize(string(string.concat(bytes(projectName), "token")), "CO2", projectName, projectAddr);
        CarbonCreditToken(tokenAddr).mint(address(this), availableCredits);
        deployedProjects[projectAddr] = CarbonProjectStruct(projectName, projectAddr, tokenAddr);
        return (projectAddr, tokenAddr);
    }

    function buyCarbonCreditForward(address projectAddress, address buyer, uint256 amount, uint256 toVintage, uint256 endPrice) external onlyOwner {
        CarbonProjectStruct memory carbonProject = deployedProjects[projectAddress];
        CarbonProject(projectAddress).safeMint(buyer); // mint NFT to buyer as proof of ownership of the carbon credits
        CarbonCreditToken(carbonProject.carbonToken).approve(address(carbonVault), amount);
        carbonVault.lockTokens(carbonProject.carbonToken, buyer, amount, toVintage, endPrice);
    }

    function allowRecipientForToken(address tokenAddr, address recipient) external onlyOwner {
        CarbonCreditToken(tokenAddr).addAllowedRecipient(recipient);
    } 

    function freezeToken(address tokenAddr) external onlyOwner {
        CarbonCreditToken(tokenAddr).pause();
    }

    function unFreezeToken(address tokenAddr) external onlyOwner {
        CarbonCreditToken(tokenAddr).unpause();
    }

    function burnToken(address tokenAddr, uint256 amount) external onlyOwner {
        CarbonCreditToken(tokenAddr).burn(amount);
    }

}