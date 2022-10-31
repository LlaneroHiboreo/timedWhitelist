//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Whitelist{
    // Address to receive payments after time or account limit exceeds
    address payable public immutable feeAccount;

    // Max number of addresses
    uint8 public maxWhitelistedAddresses;

    // Counter of actual number of listed addresses
    uint8 public numAddressesWhitelisted;

    // Amount fee to enter whitelist
    uint256 public feeAmount;
    // variable to store deploy date
    uint256 deployDate;

    // Mapping to keep track of saved addresses
    mapping(address => bool) public whitelistedAddresses;

    // event to notify a new address is submitted
    event Added(address indexed _user, uint8 _numAddressesWhitelisted);
    event PaidAdded(address indexed _user, uint8 _numAddressesWhitelisted);

    //  Constructor, set max number of adrs
    constructor(uint8 _maxWhitelistedAddresses, uint256 _feeAmount){
        maxWhitelistedAddresses = _maxWhitelistedAddresses;
        feeAmount=_feeAmount;
        deployDate=block.timestamp;
        feeAccount=payable(msg.sender);
    }

    // function to add address free
    function _freeAddAddressToWhitelist() internal{
        // require address is not already listed
        require(!whitelistedAddresses[msg.sender], "Address Already Listed :/");

        // require max number of adrs not achieved
        require(numAddressesWhitelisted < maxWhitelistedAddresses, "Max Number of Addresses Achieved :(");

        // add address to mapping
        whitelistedAddresses[msg.sender] = true;

        // update counter
        numAddressesWhitelisted++;

        // emit event
        emit Added(msg.sender, numAddressesWhitelisted);
    }

    function _paidAddAddressToWhitelist() internal{
        // require address is not already listed
        require(!whitelistedAddresses[msg.sender], "Address Already Listed :/");
        require(numAddressesWhitelisted < maxWhitelistedAddresses, "Max Number of Addresses Achieved :(");
        
        // add address to mapping
        whitelistedAddresses[msg.sender] = true;

        // update counter
        numAddressesWhitelisted++;

        // emit event
        emit PaidAdded(msg.sender, numAddressesWhitelisted);
    }

    // Function to add address
    function addAddressToWhitelist() public payable{
        if((block.timestamp <= (deployDate + 5 minutes))){
            _freeAddAddressToWhitelist();
        }else{
            feeAccount.transfer(feeAmount);
            _paidAddAddressToWhitelist();
        }
    }

}