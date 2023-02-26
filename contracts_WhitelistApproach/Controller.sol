// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "./MinimalProxyFactory.sol";
import "./CarbonProject.sol";
import "./CarbonForwardToken.sol";
import "./Storage.sol";

contract Controller is Ownable, ProjectsStorage {

    MinimalFactory public minimalFactory;

    constructor(address _minimalFactoryAddr) {
        minimalFactory = MinimalFactory(_minimalFactoryAddr);
    }

    function initializeNewProject(
        string calldata projectName, 
        string calldata projectSymbol,
        uint256 availableCredits
    ) external onlyOwner returns(address, address){
        (address projectAddr, address tokenAddr) = minimalFactory.createProjectAndToken();
        CarbonProject(projectAddr).initialize(projectName, projectSymbol, availableCredits);
        CarbonCreditToken(tokenAddr).initialize(
            string(string.concat(bytes(projectName), "token")), 
            "CO2", 
            projectName, 
            projectAddr, 
            address(this),
            availableCredits
        );
        deployedProjects[projectAddr] = CarbonProjectStruct(projectName, projectAddr, tokenAddr);
        return (projectAddr, tokenAddr);
    }

    function buyCarbonCreditForward(address projectAddress, address buyer, uint256 amount, uint256 toVintage, uint256 endPrice) external onlyOwner returns(Transaction memory) {
        CarbonProjectStruct memory carbonProject = deployedProjects[projectAddress];
        uint256 proofId = CarbonProject(projectAddress).safeMint(buyer); // mint NFT to buyer as proof of ownership of the carbon credits
        Transaction memory transactionData = Transaction(buyer, projectAddress, amount, endPrice, block.timestamp, toVintage, proofId);
        return CarbonCreditToken(carbonProject.carbonToken).addWhitelistedUser(transactionData);
    }

    // function allowRecipientForToken(address tokenAddr, address recipient) external onlyOwner {
    //     CarbonCreditToken(tokenAddr).addAllowedRecipient(recipient);
    // } 

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