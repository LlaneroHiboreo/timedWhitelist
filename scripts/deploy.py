from brownie import Whitelist, accounts, network
from web3 import Web3
import json

def deploy_whitelist():
    if network.show_active() == 'development':
        deployer=accounts[0]
        print("[*] Using development - ganache network")
    elif network.show_active() == 'goerli_infura_node':
        deployer = accounts.load('blockchain_courses')
        print("[*] Using Infura node in Goerli network")    
    
    # load config with values to deploy
    conf=load_config()
    max_listed_addresses=conf["whitelist"]["max_listed_addresses"] # max number of addresses to be stored
    starting_fee_amount=conf["whitelist"]["starting_fee_amount"] # initial cost to enter whitelist
    time_interval=conf["whitelist"]["time_interval"] # time in seconds to wait until price increase
    # deploy contract
    deployed_contract = Whitelist.deploy(max_listed_addresses, starting_fee_amount, time_interval,{'from':deployer})
    
    return deployed_contract

def load_config():
    # Opening JSON file
    f = open('/Users/blackshuck/Documents/BLOCKCHAIN/learnweb3dao/timedWhitelist/helpers/config.json')
    # Load JSON file
    conf = json.load(f)
    return conf
    
def main():
    deploy_whitelist()
    
