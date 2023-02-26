// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./Storage.sol";

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
}

contract CarbonForwardToken is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, PausableUpgradeable, OwnableUpgradeable, UUPSUpgradeable, ProjectsStorage {
    
    mapping(address => bool) public allowedRecipients;
    mapping(address => Transaction[]) public whitelisedTransactions;

    Transaction[] public approvedTransactions;

    address public projectAddress;
    address public controllerAddress;

    string public projectName;

    uint256 public availableCreditsToSell;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    modifier onlyOwnerOrController {
        require(msg.sender == controllerAddress || msg.sender == owner(), "not the controller");
        _;
    }

    function initialize(string calldata name, string calldata symbol, string calldata _projectName, address _projectAddress, address _controllerAddress, uint256 _availableCreditsToSell) initializer public {
        __ERC20_init(name, symbol);
        __ERC20Burnable_init();
        __Pausable_init();
        __Ownable_init();
        __UUPSUpgradeable_init();
        projectAddress = _projectAddress;
        projectName = _projectName;
        controllerAddress = _controllerAddress;
        availableCreditsToSell = _availableCreditsToSell;
    }

    function checkConditionsForMint(address buyer, uint256 transactionId) internal returns(uint256){
        Transaction memory transaction = whitelisedTransactions[buyer][transactionId];
        require(availableCreditsToSell >= transaction.amountBought, "not enough credits available");
        require(transaction.endDate <= block.timestamp, "not approved");
        return transaction.amountBought;
    }

    // function getWhitelistedTransactions(address buyer, uint256 index) public view returns(address,address,uint256,uint256) {
    //     Transaction memory transaction = whitelisedTransactions[buyer][index];
    //     return (transaction.buyerAddress, transaction.projectAddress, transaction.amountBought, transaction.proofId);
    // }

    function pause() public onlyOwnerOrController {
        _pause();
    }

    function unpause() public onlyOwnerOrController {
        _unpause();
    }

    function claim(uint256 transactionId) external {
        uint256 amountToMint = checkConditionsForMint(msg.sender, transactionId);
        availableCreditsToSell -= amountToMint;
        _mint(msg.sender, amountToMint);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwnerOrController
        override
    {}

    // function addAllowedRecipient(address recipientAddress) external onlyOwnerOrController {
    //     require(recipientAddress != address(0), "recipient cannot be address 0");
    //     allowedRecipients[recipientAddress] = true;
    // }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        // require(allowedRecipients[to],"recipient not allowed to receive tokens");
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        // require(allowedRecipients[to],"recipient not allowed to receive tokens");
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function addWhitelistedUser(Transaction memory transactionData) external onlyOwnerOrController returns (Transaction memory) {
        // check if buyer owns an NFT from this project with transactionData.proofId
        require(IERC721(projectAddress).ownerOf(transactionData.proofId) == transactionData.buyerAddress, "no access");
        whitelisedTransactions[transactionData.buyerAddress].push(transactionData);
        approvedTransactions.push(transactionData);
        return transactionData;
    }

}