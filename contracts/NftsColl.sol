// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./../interfaces/IWhitelist.sol";

contract NftsColl is ERC721Enumerable, Ownable{
    // variable to store URI
    string baseTokenURI;

    // variable to store price of nft
    uint256 public price;

    // add stopper to pause contract in case of emergency
    bool public paused;

    // maximum number of collectibles
    uint256 public maxTokenIds;

    // counter of number of collectibles
    uint256 public tokenIds;

    // Whitelist contract instance
    IWhitelist whitelist;

    // Boolean to keep track if presale started or not
    bool public presaleStarted;

    // timestamp for when presale should end
    uint256 public presaleEnded;

    // Modifier that restricts functions when paused
    modifier onlyWhenNotPaused {
        require(!paused, "Contract currently paused");
        _;
    }

    // Initialize constructor
    constructor(string memory baseURI, address _whitelistContract, uint256 _price, uint256 _maxTokens) ERC721("Test Nfts", "TNFT"){
        baseTokenURI=baseURI;
        whitelist=IWhitelist(_whitelistContract);
        price=_price;
        maxTokenIds=_maxTokens;
    }

    // Function to start presale
    function startPresale() public onlyOwner{
        presaleStarted=true;
        presaleEnded=block.timestamp + 1 minutes;
    }

    // Function to mint in presale
    function presaleMint() public onlyWhenNotPaused{
        // requirements to use presale function
        require(presaleStarted && block.timestamp < presaleEnded, "Presale is not running :-/");
        require(whitelist.whitelistedAddresses(msg.sender), "You are not whitelisted :(");
        require(tokenIds <= maxTokenIds, "Max number of tokens achieved");
        
        // update tokenID
        tokenIds +=1;

        // safe mint tokens
        _safeMint(msg.sender, tokenIds);
    }

    // Function to mint collectibles after presale
    function mint() public payable onlyWhenNotPaused{
        // requirements to mint after presale
        require(presaleStarted && block.timestamp >= presaleEnded, "Presale has not finished yet!");
        require(tokenIds <= maxTokenIds, "Max number of tokens achieved");
        require(msg.value >= price, "Ether sent is not correct");
        // update tokenID
        tokenIds +=1;
        // safe mint tokens
        _safeMint(msg.sender, tokenIds);
    }

    // Set URI for collectible
    function _baseURI() internal view virtual override returns(string memory){
        return baseTokenURI;
    }

    // Function to pause minting
    function setPaused(bool val) public onlyOwner {
        paused = val;
    }

    // Function to withdraw money in contract
    function withdraw() public onlyOwner{
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    // Function to receive ether, msg.data must be empty
    receive() external payable{}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}