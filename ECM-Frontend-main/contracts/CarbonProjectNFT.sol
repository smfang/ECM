// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract CarbonProject is Initializable, ERC1155Upgradeable, OwnableUpgradeable, ERC1155BurnableUpgradeable, UUPSUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor

    uint256 public projectId;
    uint256 public availableCredits; // available carbon credits to sell
    uint256 public startDate;
    uint256 public endDate;

    string public projectType;

    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner, string calldata projectName ,string calldata symbol, uint256 _availableCredits) initializer public {
        __ERC1155_init(projectName);
        __Ownable_init();
        __ERC1155Burnable_init();
        __UUPSUpgradeable_init();
        availableCredits = _availableCredits;
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        onlyOwner
    {
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    function setAvailableCredits(uint256 _availableCredits) external onlyOwner {
        availableCredits = _availableCredits;
    }
}
