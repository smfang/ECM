// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import "./MinimalProxyFactory.sol";
import "./CarbonProjectNFT.sol";
import "./CarbonCreditTokenUpgradeable.sol";

contract Controller is Ownable, ProjectsStorage {

    MinimalProxyFactory public minimalFactory;

    constructor(address _minimalFactoryAddr) Ownable(msg.sender) {
        minimalFactory = MinimalProxyFactory(_minimalFactoryAddr);
    }

    function initializeNewProject(
        string calldata projectName, 
        uint256 availableCredits,
        uint256 priceOfCarbonCreditInETH
    ) external onlyOwner returns(address, address){
        (address projectAddr, address tokenAddr) = minimalFactory.createProjectAndToken();
        CarbonProject(projectAddr).initialize(projectName);
        CarbonCreditTokenUpgradeable(tokenAddr).initialize(
            string(string.concat(projectName, "token")), 
            "CO2", 
            projectName, 
            availableCredits,
            priceOfCarbonCreditInETH,
            projectAddr
        );
        deployedProjects[projectAddr] = CarbonProjectStruct(projectName, projectAddr, tokenAddr);
        return (projectAddr, tokenAddr);
    }

    function freezeToken(address tokenAddr) external onlyOwner {
        CarbonCreditTokenUpgradeable(tokenAddr).pause();
    }

    function unFreezeToken(address tokenAddr) external onlyOwner {
        CarbonCreditTokenUpgradeable(tokenAddr).unpause();
    }

    function burnToken(address tokenAddr, uint256 amount) external onlyOwner {
        CarbonCreditTokenUpgradeable(tokenAddr).burn(amount);
    }

}