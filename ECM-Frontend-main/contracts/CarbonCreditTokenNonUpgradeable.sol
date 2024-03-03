// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ProjectsStorage.sol";

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeMint(address to) external returns(uint256);
}

contract CarbonCreditToken is ERC20, ERC20Burnable, Ownable, ProjectsStorage {
    
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
    // mapping(address => Transaction[]) public whitelisedTransactions;

    // array to keep track of call options bought by users, will later be used to check and execute them
    Option[] public options;
    // array to keep track of pre purchases
    PrePurchase[] public prePurchaseArray;

    // address of this carbon credit project NFT Collection which is basically a collection of "tickets" 
        // why do we even need this now ? if flow is buy on chain and get on chain tokens 
        // instead of get off chain first and then clone on the chain 
    address public carbonProjectNFT;

    address public controllerAddress;

    string public projectName;

    uint256 public availableCreditsForPrePurchase;
    uint256 public availableCreditsForOptions;
    uint256 public tokenMintPriceInETH;
    uint256 public premium;

    bool public paused;

    constructor(address initialOwner)
        ERC20("CarbonCreditToken", "CCT")
        Ownable(initialOwner)
    {}

    modifier onlyOwnerOrController {
        require(msg.sender == controllerAddress || msg.sender == owner(), "not the controller");
        _;
    }

    modifier checkIfPaused {
        require(paused == false, "Contract is paused");
        _;
    }

    function pause() public onlyOwnerOrController {
        paused = true;
    }

    function unpause() public onlyOwnerOrController {
        paused = false;
    }

    function transfer(address to, uint256 amount) public checkIfPaused virtual override returns (bool) {
        // require(allowedRecipients[to],"recipient not allowed to receive tokens");
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public checkIfPaused virtual override returns (bool) {
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

    function prePurchase(uint256 amount) public payable {
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
    } 

    function createCallOption(uint256 _amount, uint256 _strike, uint256 _expiry) public onlyOwnerOrController {
        require(availableCreditsForOptions - _amount >= 0, "Out of credits");
        options.push(Option(_strike, block.timestamp, _expiry, _amount, Status.NOT_OWNED, OptionType.CALL, options.length, payable(address(this)), payable(0x0000000000000000000000000000000000000000)));
    } 

    // function createPutOption(uint256 _amount, uint256 _strike, uint256 _expiry) public onlyOwnerOrController {
    //     require(availableCreditsForOptions - _amount >= 0, "Out of credits");
    //     options.push(Option(_strike, block.timestamp, _expiry, _amount, Status.NOT_OWNED, OptionType.PUT, options.length, payable(address(this)), payable(0x0000000000000000000000000000000000000000)));
    // } 

    function buyCallOption(uint256 _optionId) public payable {
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
    } 

    function executeCallOption(uint256 callOptionId) public payable{
        require(options[callOptionId].buyer == msg.sender, "You do not own this option");
        require(options[callOptionId].status == Status.IN_PROGRESS, "Option not available");
        require(options[callOptionId].startDate <= block.timestamp, "Option not yet ready");
        // user has 3 days to executed the call option when expiry date is reached
        require(block.timestamp >= options[callOptionId].expiry && block.timestamp < options[callOptionId].expiry + 3 days , "Option is expired");
        uint exerciseValInETH = options[callOptionId].strike*options[callOptionId].amount;
        require(msg.value == exerciseValInETH, "Incorrect ETH amount sent to exercise");
        // require(IERC20Upgradeable(carbonToken).transfer(msg.sender, options[callOptionId].amount), "Error: buyer was not paid");
        _mint(msg.sender, options[callOptionId].amount);
        options[callOptionId].status = Status.EXERCISED;
    }
}