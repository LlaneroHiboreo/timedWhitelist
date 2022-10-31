from brownie import Whitelist, accounts, network
from web3 import Web3

def deploy_whitelist():
    if network.show_active() == 'development':
        deployer=accounts[0]
        
    elif network.show_active() == 'goerli_infura_node':
        deployer = accounts.load('blockchain_courses')
    
    deployed_contract = Whitelist.deploy(5, 10,{'from':deployer})
    
    return deployed_contract

def main():
    deploy_whitelist()