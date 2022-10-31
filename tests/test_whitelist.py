import brownie
from brownie import accounts
from web3 import Web3
from scripts.deploy import deploy_whitelist
import pytest

#@pytest.fixture
def test_whitelist():

    # deploy smart contract
    white_sc = deploy_whitelist()
    
    # loop to add addresses to the whitelist
    for id in range(1, 6):
        white_sc.addAddressToWhitelist({'from':accounts[id]})
    
    # after 5 accounts added check if true
    assert white_sc.whitelistedAddresses(accounts[1]) == True
    assert white_sc.whitelistedAddresses(accounts[2]) == True
    assert white_sc.whitelistedAddresses(accounts[3]) == True
    assert white_sc.whitelistedAddresses(accounts[4]) == True
    assert white_sc.whitelistedAddresses(accounts[5]) == True

    # check if actual number of addresses is correct
    assert white_sc.numAddressesWhitelisted() == 5
    
    # check if reverts adding duplicated address (max 5)
    with brownie.reverts("Address Already Listed :/"):
        white_sc.addAddressToWhitelist({'from':accounts[1]})
    
    