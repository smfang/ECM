// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./ProjectsStorage.sol";
import "./CarbonProjectNFT.sol";

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeMint(address to) external returns(uint256);
}

contract CarbonCreditTokenUpgradeable is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, PausableUpgradeable, OwnableUpgradeable, UUPSUpgradeable, ProjectsStorage {
    
    enum Status{NOT_OWNED, IN_PROGRESS, FAILED, CANCELED, SUCCEEDED, EXERCISED, EXPIRED}
    enum OptionType{CALL, PUT}

    struct Option {
        uint strike; //Price in USD (18 decimal places) option allows buyer to purchase tokens at
        uint startDate; //From this timestamp the user can execute the call option
        uint expiry; //Unix timestamp of expiration time
        uint amount; //Amount of tokens the option contract is for
        Status status;
        OptionType optType;
        uint id; //Unique ID of option, also array index
        address payable writer; //Issuer of option
        address payable buyer; //Buyer of option
    }

    // buy an Option and you have the right to buy X tokens at Y time with Z price (discount)
    // if you pre-purchase, you get the tokens on spot and you buy them at a 50% discount from their current price
    // need to keep 50% of token supply for pre-purchase and other 50% for option trading
    struct PrePurchase {
        uint price; //Price in wei (18 decimal places) option allows buyer to purchase tokens at
        // uint claimDate; //Unix timestamp of expiration time
        uint amount; //Amount of tokens the option contract is for
        uint id;
        Status status;
        address payable buyer; //Buyer of option
    }

    // only these addresses will be able to receive the token --> if we make it mintable at buy time then this is not needed
    mapping(address => bool) public allowedRecipients;
    mapping(address => Transaction[]) public whitelisedTransactions;

    // array to keep track of call options bought by users, will later be used to check and execute them
    Option[] public options;
    // array to keep track of pre purchases
    PrePurchase[] public prePurchaseArray;

    // address of this carbon credit project NFT Collection which is basically a collection of "tickets" 
        // why do we even need this now ? if flow is buy on chain and get on chain tokens 
        // instead of get off chain first and then clone on the chain 
    // address public carbonProjectNFT;

    string public projectName;

    uint256 public availableCreditsForPrePurchase;
    uint256 public availableCreditsForOptions;
    uint256 public tokenMintPriceInETH;
    uint256 public premium;

    bool public availableToBuy = true;
    bool public optionExecutionEnabled = true;

    CarbonProject public carbonProject;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    modifier whenAvailableToBuy {
        require(availableToBuy == true, "Not available");
        _;
    }

    modifier whenOptionExecutionEnabled {
        require(optionExecutionEnabled == true, "Not available");
        _;
    }

    function initialize(string calldata name, string calldata symbol, string calldata _projectName, uint256 _availableCreditsForPrePurchase, uint256 _tokenMintPriceInETH, address _projectAddr) initializer public {
        __ERC20_init(name, symbol);
        __ERC20Burnable_init();
        __Pausable_init();
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        // carbonProjectNFT = _projectAddress;
        projectName = _projectName;
        availableCreditsForPrePurchase = _availableCreditsForPrePurchase;
        tokenMintPriceInETH = _tokenMintPriceInETH;
        carbonProject = CarbonProject(_projectAddr);
        premium = 10000;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    function setAvailableCreditsForOptions(uint256 availableCredits) external onlyOwner {
        availableCreditsForOptions = availableCredits;
    }

    // function addAllowedRecipient(address recipientAddress) external onlyOwner {
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

    function calculateDiscount(uint256 discount, uint256 amount) public view returns (uint256 price) {
        uint256 price = ((tokenMintPriceInETH * amount) * discount) / 100;
        return price;
    }

    function prePurchase(uint256 amount) public whenAvailableToBuy payable {
        // buy at a discount% 
        // 3000 ==> 30% discount
        uint256 price = (tokenMintPriceInETH * amount) - calculateDiscount(30, amount);
        require(msg.value >= price, "Incorrect amount of ETH sent for premium");
        require(availableCreditsForPrePurchase - amount >= 0, "Out of supply");
        PrePurchase memory prePurchaseObj = PrePurchase(tokenMintPriceInETH, amount, prePurchaseArray.length + 1, Status.SUCCEEDED, payable(msg.sender));
        prePurchaseArray.push(prePurchaseObj);
        _mint(msg.sender, prePurchaseObj.amount);
        availableCreditsForPrePurchase -= amount;
        // return remaining ETH if any
        if(msg.value - price > 0) {
            payable(msg.sender).transfer(msg.value - price);
        }
        uint256 currentIndex = latestTransactionIndex[msg.sender];
        transactions[msg.sender][currentIndex] = Transaction(
            msg.sender,
            address(carbonProject),
            amount,
            price,
            block.timestamp,
            carbonProject.getEndDate(),
            carbonProject.getStartDate(),
            false
        );
        latestTransactionIndex[msg.sender]++;
    } 

    function createCallOption(uint256 _amount, uint256 _strike, uint256 _expiry) public onlyOwner {
        require(availableCreditsForOptions - _amount >= 0, "Out of credits");
        options.push(Option(_strike, block.timestamp, _expiry, _amount, Status.NOT_OWNED, OptionType.CALL, options.length, payable(address(this)), payable(0x0000000000000000000000000000000000000000)));
    } 

    // function createPutOption(uint256 _amount, uint256 _strike, uint256 _expiry) public onlyOwner {
    //     require(availableCreditsForOptions - _amount >= 0, "Out of credits");
    //     options.push(Option(_strike, block.timestamp, _expiry, _amount, Status.NOT_OWNED, OptionType.PUT, options.length, payable(address(this)), payable(0x0000000000000000000000000000000000000000)));
    // } 

    function buyCallOption(uint256 _optionId) public whenAvailableToBuy payable {
        require(msg.value >= premium, "Incorrect amount of ETH sent for premium");
        Option memory option = options[_optionId];
        require(option.buyer == payable(0x0000000000000000000000000000000000000000), "Option already bought");
        require(option.status == Status.NOT_OWNED, "Option already owned");
        option.buyer = payable(msg.sender);
        option.status = Status.IN_PROGRESS;
        require(availableCreditsForOptions - option.amount >= 0, "Out of supply");
        availableCreditsForOptions -= option.amount;
        options[_optionId] = option;
        if(msg.value - premium > 0){
            payable(msg.sender).transfer(msg.value - premium);
        }
        uint256 currentIndex = latestTransactionIndex[msg.sender];
        transactions[msg.sender][currentIndex] = Transaction(
            msg.sender,
            address(carbonProject),
            option.amount,
            option.strike,
            block.timestamp,
            carbonProject.getEndDate(),
            carbonProject.getStartDate(),
            true
        );
        latestTransactionIndex[msg.sender]++;
    } 

    function executeCallOption(uint256 callOptionId) public whenOptionExecutionEnabled payable{
        Option memory option = options[callOptionId];
        require(option.buyer == msg.sender, "You do not own this option");
        require(option.status == Status.IN_PROGRESS, "Option not available");
        require(option.startDate <= block.timestamp, "Option not yet ready");
        // user has 3 days to executed the call option when expiry date is reached
        require(block.timestamp >= option.expiry && block.timestamp < option.expiry + 3 days , "Option is expired");
        uint exerciseValInETH = option.strike * option.amount;
        require(msg.value == exerciseValInETH, "Incorrect ETH amount sent to exercise");
        // require(IERC20Upgradeable(carbonToken).transfer(msg.sender, options[callOptionId].amount), "Error: buyer was not paid");
        _mint(msg.sender, option.amount);
        options[callOptionId].status = Status.EXERCISED;

        uint256 currentIndex = latestTransactionIndex[msg.sender];
        transactions[msg.sender][currentIndex] = Transaction(
            msg.sender,
            address(carbonProject),
            option.amount,
            option.strike,
            block.timestamp,
            carbonProject.getEndDate(),
            carbonProject.getStartDate(),
            true
        );
        latestTransactionIndex[msg.sender]++;
    }
}