from brownie import NFTMarketplace, HalbornNFT, ApeCoin, accounts


### deploy NFT token, ApeCoin erc-20 and MarketPlace contracts

### rerun this script after every exploit
# some of the state changes made by exploit might interrupt the proper execution of the next PoC!


def main():
    # create accounts for the contract owners
    nft_owner = accounts[0]
    ape_owner = accounts[1]
    market_owner = accounts[2]

    nft_contract = HalbornNFT.deploy({"from": nft_owner})
    ape_contract = ApeCoin.deploy({"from": ape_owner})
    market_contract = NFTMarketplace.deploy(
        market_owner, ape_contract.address, nft_contract.address, {"from": market_owner}
    )
