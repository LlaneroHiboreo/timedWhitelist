from brownie import NftsColl, accounts, network
from web3 import Web3
import json

def deploy_nfts():
    if network.show_active() == 'development':
        deployer=accounts[0]
        print("[*] Using development - ganache network")
    elif network.show_active() == 'goerli_infura_node':
        deployer = accounts.load('blockchain_courses')
        print("[*] Using Infura node in Goerli network")    
    
    # load config with values to deploy
    conf=load_config()
    base_uri=conf["collectibles"]["baseURI"]
    whitelist_adrs=conf["collectibles"]["whitelistaddress"]
    price=conf["collectibles"]["price"]
    maxtokens=conf["collectibles"]["maxtokens"]

    # deploy contract
    deployed_contract = NftsColl.deploy(base_uri, whitelist_adrs, price, maxtokens, {'from':deployer})
    
    return deployed_contract

def load_config():
    # Opening JSON file
    f = open('/Users/blackshuck/Documents/BLOCKCHAIN/learnweb3dao/timedWhitelist/helpers/config.json')
    # Load JSON file
    conf = json.load(f)
    return conf
    
def main():
    deploy_nfts()
    
