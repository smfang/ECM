// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./CarbonProject.sol";
import "./CarbonVault.sol";
import "./CarbonCreditToken.sol";

contract MinimalFactory is Ownable {

    address public carbonVault;
    address public projectERC721Preset;
    address public carbonCreditTokenPreset;
    address public controllerAddress;

    modifier onlyController {
        require(msg.sender == controllerAddress, "not the controller");
        _;
    }

    function setController(address _controllerAddr) external onlyOwner {
        controllerAddress = _controllerAddr;
    }

    function setVault(address _carbonVault) external onlyOwner {
        carbonVault = _carbonVault;
    }

    function setERC721ProjectPreset(address _projectERC721Preset) external onlyOwner {
        projectERC721Preset = _projectERC721Preset;
    }

    function setCarbonCreditTokenPreset(address _carbonCreditTokenPreset) external onlyOwner {
        carbonCreditTokenPreset = _carbonCreditTokenPreset;
    }

    function createProjectAndToken() external onlyController returns (address, address) {
        address newERC721Project = createERC721Project();
        address newCarbonCreditToken = createCarbonCreditToken();
        
        // lockCarbonCreditTokens(toVintage, carbonCreditAmount, agreedToVintagePrice, buyer, newCarbonCreditToken);

        return (newERC721Project, newCarbonCreditToken);
    }

    function createCarbonCreditToken() internal returns (address){
        address newCO2Token = Clones.clone(carbonCreditTokenPreset);
        return newCO2Token;
    }

    function createERC721Project() internal returns (address){
        address newProject = Clones.clone(projectERC721Preset);
        return newProject;
    }

}