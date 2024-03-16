// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MinimalProxyFactory is Ownable {

    address public carbonVault;
    address public projectERC1155Preset;
    address public carbonCreditTokenPreset;
    address public controllerAddress;

    modifier onlyController {
        require(msg.sender == controllerAddress, "not the controller");
        _;
    }

    constructor(address controllerAddr) Ownable(msg.sender) {
        controllerAddress = controllerAddr;
    }
    
    function setController(address _controllerAddr) external onlyOwner {
        controllerAddress = _controllerAddr;
    }

    function setVault(address _carbonVault) external onlyOwner {
        carbonVault = _carbonVault;
    }

    function setERC721ProjectPreset(address _projectERC1155Preset) external onlyOwner {
        projectERC1155Preset = _projectERC1155Preset;
    }

    function setCarbonCreditTokenPreset(address _carbonCreditTokenPreset) external onlyOwner {
        carbonCreditTokenPreset = _carbonCreditTokenPreset;
    }

    function createProjectAndToken() external onlyController returns (address, address) {
        address newERC721Project = createProject();
        address newCarbonCreditToken = createCarbonCreditToken();
        
        // lockCarbonCreditTokens(toVintage, carbonCreditAmount, agreedToVintagePrice, buyer, newCarbonCreditToken);

        return (newERC721Project, newCarbonCreditToken);
    }

    function createCarbonCreditToken() internal returns (address){
        address newCO2Token = Clones.clone(carbonCreditTokenPreset);
        return newCO2Token;
    }

    function createProject() internal returns (address){
        address newProject = Clones.clone(projectERC1155Preset);
        return newProject;
    }

}