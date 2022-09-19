from brownie import HalbornToken, accounts
from brownie import chain


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

    # halborn = HalbornToken[-1]
    ### create accounts
    A_acc = accounts[1]
    B_acc = accounts[2]
    C_acc = accounts[3]
    D_acc = accounts[4]

    ### execute newTimeLock from the user A_acc
    # I have transfered tokens to A_acc previously (See deploy script)
    # amount = 100 tokens
    # vest time = now + 1 second
    # clifftime = now + 6 months
    # disbursement period  = 1 year
    halborn.newTimeLock(
        100000000000000000000,
        chain.time() + 1,
        chain.time() + 15770000,
        31540000,
        {"from": A_acc},
    )

    ### "travel" in time to the end of the cliff period
    chain.mine(blocks=1, timestamp=chain.sleep(15770005))

    ### After the cliff period is over, A_acc user has ~50 tokens released,
    # and they decide to transfer tokens to other accounts

    ### This transfer reaches it's destination
    halborn.transfer(B_acc, 20000000000000000000, {"from": A_acc})

    ### And this transaction reverts with the overflow REVERT opcode
    halborn.transfer(C_acc, 20000000000000000000, {"from": A_acc})

    # Means that A_acc user won't be able to transfer released tokens. (at first, i thought of 'forever')
    # but, no :) After reading your report, i realised that tokens are locked 'till the end of disbursement period'

    print("A_acc balance is " + str(halborn.balanceOf(A_acc)))
    print("B_acc balance is " + str(halborn.balanceOf(B_acc)))
    print("C_acc balance is " + str(halborn.balanceOf(C_acc)))
    print("D_acc balance is " + str(halborn.balanceOf(D_acc)))
