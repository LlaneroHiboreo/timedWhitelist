// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import './../interfaces/INftsColl.sol';

contract tokenICO is ERC20, Ownable{
    // Price of 1 token
    uint256 public constant tokenPrice = 1 ether;

    // 1 nft gives 10 tokens
    uint256 public constant tokensPerNFT = 10 * 10**18;

    // Max total supply of tokens for ICO
    uint256 public constant maxTotalSupply = 10000 * 10**18;

    // Nfts instance
    INftsColl nftColl;

    // mapping to keep track of which  tokenIds have been claimed
    mapping(uint256=>bool) public tokenIdsClaimed;

    // Constructor
    constructor(address _NftsCollContract) ERC20("Collectibles", "CX"){
        nftColl= INftsColl(_NftsCollContract);
    }

    function mint(uint256 amount) public payable{
        // Calculate amount to pay
        uint256 requiredAmount = tokenPrice*amount;
        // Check amount sended is enough
        require(msg.value >= requiredAmount);
        //change units
        uint256 amountWithDecimals = amount * 10**18;
        // check if amount minting exceeds total supply
        require((totalSupply() + amountWithDecimals)<=maxTotalSupply, "Exceeds the max total supply available");
        // internal function erc20, mints new tokens increasing total supply
        _mint(msg.sender, amountWithDecimals);
    }

    function claim() public {
        // get number of nfts of sender
        uint256 balance = nftColl.balanceOf(msg.sender);
        // if balance is 0 revert
        require(balance > 0, "0 Balance of presale nfts");

        // amount keeps track of number of unclaimed tokenIds
        uint256 amount = 0;

        // loop over balance of sender to claim ids
        for(uint i=0; i<balance; i++){
            uint256 tokenId = nftColl.tokenOfOwnerByIndex(msg.sender, i);
            // if tokenID not claimed increase amount
            if(!tokenIdsClaimed[tokenId]){
                amount+=1;
                tokenIdsClaimed[tokenId] = true;
            }   
        }

        // require amount > 0 to claim
        require(amount > 0, "No more tokens to claim");

        // mint tokens
        _mint(msg.sender, amount* tokensPerNFT );

    }

    function withdraw() public onlyOwner{
        uint256 amount = address(this).balance;
        address _owner = owner();
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
    
    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

}