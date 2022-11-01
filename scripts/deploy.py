from brownie import Whitelist, accounts, network
from web3 import Web3

def deploy_whitelist():
    if network.show_active() == 'development':
        deployer=accounts[0]
        print("[*] Using development - ganache network")
    elif network.show_active() == 'goerli_infura_node':
        deployer = accounts.load('blockchain_courses')
        print("[*] Using Infura node in Goerli network")    
    # define variables to deploy
    max_listed_addresses=100 # max number of addresses to be stored
    starting_fee_amount=0 # initial cost to enter whitelist
    time_interval=10 # time in seconds to wait until price increase
    # deploy contract
    deployed_contract = Whitelist.deploy(max_listed_addresses, starting_fee_amount, time_interval,{'from':deployer})
    
    return deployed_contract

def main():
    deploy_whitelist()