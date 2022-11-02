import brownie
from brownie import accounts
from web3 import Web3
from scripts.deploy_nfts import deploy_nfts
from scripts.deploy import deploy_whitelist
import pytest, time

@pytest.fixture
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
    
    # perform upkeep 
    msg = "Check upkeep"
    arr = bytes(msg, 'utf-8')
    white_sc.performUpkeep(arr)
    # check if fee amount increased
    assert white_sc.feeAmount() == 0

    # wait interval and perform upkeep
    print("[+] Going to sleep!")
    time.sleep(10)
    tx = white_sc.performUpkeep(arr)
    tx.wait(1)
    # check if fee amount increased
    assert white_sc.feeAmount() == Web3.toWei(2, 'ether')

    return white_sc

def test_nfts(test_whitelist):
    # deploy nft contract
    nft_sc = deploy_nfts()
    
    # define dplyr
    dplyr=accounts[0]
    
    # check correct price
    print("[+] Price SHould be same")
    assert nft_sc.price() == Web3.toWei(5, 'ether')

    assert nft_sc.owner() == accounts[0] # check that account 0 is the owner
    
    # start pre$ale
    nft_sc.startPresale({'from':accounts[0]})
    assert nft_sc.presaleStarted() == True

    # min presale (do not reach limit) - wait interval
    nft_sc.presaleMint({'from':accounts[1]})
    nft_sc.presaleMint({'from':accounts[2]})
    nft_sc.presaleMint({'from':accounts[3]})
    nft_sc.presaleMint({'from':accounts[4]})
    
    # check balance of user 1 should be 1
    assert nft_sc.balanceOf(accounts[1]) == 1
    assert nft_sc.balanceOf(accounts[2]) == 1
    assert nft_sc.balanceOf(accounts[3]) == 1
    assert nft_sc.balanceOf(accounts[4]) == 1
    print("[+] Users have correct balance!!")

    # wait until presale is finished
    time.sleep(360)

    # check if reverts when presale is ended
    with brownie.reverts("Presale is not running :-/"):
        nft_sc.presaleMint({'from':accounts[4]})

    #  public mint - paid
    amount = Web3.toWei(5, 'ether')
    # check revert price
    with brownie.reverts("Ether sent is not correct"):
        nft_sc.mint({'from': accounts[5], 'value':amount})
    amount = Web3.toWei(5, 'ether')
    nft_sc.mint({'from': accounts[5], 'value':amount})
    nft_sc.mint({'from': accounts[6], 'value':amount})

    # assert balances
    assert nft_sc.balanceOf(accounts[5]) == 1
    assert nft_sc.balanceOf(accounts[6]) == 1
    print("[*] Public mint Balances are correct")
    
    # check contracts amount
    assert nft_sc.balance() == Web3.toWei(10, 'ether')
    print("[+] Smart Contract balance is correct")

    # whithdraw balances
    nft_sc.withdraw({'from':accounts[0]})
    # check contracts amount
    assert nft_sc.balance() == Web3.toWei(0, 'ether')
    print("[+] Correct SC contract withdraw ")