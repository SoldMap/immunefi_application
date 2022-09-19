from brownie import HalbornToken, accounts

### you can run this script once and execute PoC scripts one by one after it
# None of the state changes made by these PoCs won't be able to interrupt the proper execution of the next exploit


def main():
    steve = accounts[0]
    amount_to_mint = 10000000000000000000000
    random_merkle_tree_root_hash = (
        "0x87c2d362de99f75a4f2755cdaaad2d11bf6cc65dc71356593c445535ff28f43d"
    )

    halborn = HalbornToken.deploy(
        "Halborn Token",
        "HT",
        amount_to_mint,
        steve,
        random_merkle_tree_root_hash,
        {"from": steve},
    )

    ### This one is for the calcMaxTransferable POC.
    ### Here I transfer 100 tokens to the A_acc
    amount_to_transfer = 100000000000000000000
    halborn.transfer(accounts[1], amount_to_transfer, {"from": steve}).wait(1)
