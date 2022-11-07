from brownie import tokenICO, accounts, network
from web3 import Web3
import json

def deploy_ico():
    if network.show_active() == 'development':
        deployer=accounts[0]
        print("[*] Using development - ganache network")
    elif network.show_active() == 'goerli_infura_node':
        deployer = accounts.load('blockchain_courses')
        print("[*] Using Infura node in Goerli network")    
    
    # load config with values to deploy
    conf=load_config()
    nft_sc = conf['collectibles']['address']

    # deploy contract
    deployed_contract = tokenICO.deploy(nft_sc, {'from':deployer})
    
    return deployed_contract

def load_config():
    # Opening JSON file
    f = open('/Users/blackshuck/Documents/BLOCKCHAIN/learnweb3dao/timedWhitelist/helpers/config.json')
    # Load JSON file
    conf = json.load(f)
    return conf
  
def main():
    deploy_ico()