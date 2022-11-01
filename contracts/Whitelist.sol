//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// imports
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

contract Whitelist is KeeperCompatibleInterface{
    // Address to receive payments after time or account limit exceeds
    address payable public immutable feeAccount;

    // Max number of addresses
    uint256 public maxWhitelistedAddresses;

    // Counter of actual number of listed addresses
    uint256 public numAddressesWhitelisted;

    // Amount fee to enter whitelist
    uint256 public feeAmount;
    
    // variable to store deploy date
    uint lastTimeStamp;
    uint interval;

    // Mapping to keep track of saved addresses
    mapping(address => bool) public whitelistedAddresses;

    // event to notify a new address is submitted
    event Added(address indexed _user, uint256 _numAddressesWhitelisted);
    event PaidAdded(address indexed _user, uint256 _numAddressesWhitelisted);

    //  Constructor, set max number of adrs
    constructor(uint256 _maxWhitelistedAddresses, uint256 _feeAmount, uint _interval){
        maxWhitelistedAddresses = _maxWhitelistedAddresses;
        feeAmount=_feeAmount;
        lastTimeStamp=block.timestamp;
        feeAccount=payable(msg.sender);
        interval=_interval;
    }

    // function to add address free
    function _AddAddressToWhitelist() internal{
        // require address is not already listed
        require(!whitelistedAddresses[msg.sender], "Address Already Listed :/");

        // require max number of adrs not achieved
        require(numAddressesWhitelisted < maxWhitelistedAddresses, "Max Number of Addresses Achieved :(");

        // add address to mapping
        whitelistedAddresses[msg.sender] = true;

        // update counter
        numAddressesWhitelisted++;
    }

    // Function to add address
    function addAddressToWhitelist() public payable{
        if(feeAmount == 0){
            _AddAddressToWhitelist();
            // emit event
            emit Added(msg.sender, numAddressesWhitelisted);
        }else{
            feeAccount.transfer(feeAmount);
            _AddAddressToWhitelist();
            // emit event
            emit PaidAdded(msg.sender, numAddressesWhitelisted);
        }
    }

    function checkUpkeep(bytes calldata /* checkData */) external override returns (bool upkeepNeeded, bytes memory /* performData */) {
        // check if enough time have passed to update price
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
    }
    
    function performUpkeep(bytes calldata /* performData */) external override {
        //We highly recommend revalidating the upkeep in the performUpkeep function
        if ((block.timestamp - lastTimeStamp) > interval ) {
            lastTimeStamp = block.timestamp;
            // increase fee price to register
            feeAmount = feeAmount + (2 ether);
        }
    }
}