// SPDX-License-Identifier: UNLICENSED
/*
██╗░░██╗░█████╗░██╗░░░░░██████╗░░█████╗░██████╗░███╗░░██╗
██║░░██║██╔══██╗██║░░░░░██╔══██╗██╔══██╗██╔══██╗████╗░██║
███████║███████║██║░░░░░██████╦╝██║░░██║██████╔╝██╔██╗██║
██╔══██║██╔══██║██║░░░░░██╔══██╗██║░░██║██╔══██╗██║╚████║
██║░░██║██║░░██║███████╗██████╦╝╚█████╔╝██║░░██║██║░╚███║
╚═╝░░╚═╝╚═╝░░╚═╝╚══════╝╚═════╝░░╚════╝░╚═╝░░╚═╝╚═╝░░╚══╝
░██████╗░█████╗░██╗░░░░░██╗██████╗░██╗████████╗██╗░░░██╗  ░█████╗░████████╗███████╗██╗
██╔════╝██╔══██╗██║░░░░░██║██╔══██╗██║╚══██╔══╝╚██╗░██╔╝  ██╔══██╗╚══██╔══╝██╔════╝╚═╝
╚█████╗░██║░░██║██║░░░░░██║██║░░██║██║░░░██║░░░░╚████╔╝░  ██║░░╚═╝░░░██║░░░█████╗░░░░░
░╚═══██╗██║░░██║██║░░░░░██║██║░░██║██║░░░██║░░░░░╚██╔╝░░  ██║░░██╗░░░██║░░░██╔══╝░░░░░
██████╔╝╚█████╔╝███████╗██║██████╔╝██║░░░██║░░░░░░██║░░░  ╚█████╔╝░░░██║░░░██║░░░░░██╗
╚═════╝░░╚════╝░╚══════╝╚═╝╚═════╝░╚═╝░░░╚═╝░░░░░░╚═╝░░░  ░╚════╝░░░░╚═╝░░░╚═╝░░░░░╚═╝
██╗░░██╗░█████╗░██╗░░░░░██████╗░░█████╗░██████╗░███╗░░██╗████████╗░█████╗░██╗░░██╗███████╗███╗░░██╗
██║░░██║██╔══██╗██║░░░░░██╔══██╗██╔══██╗██╔══██╗████╗░██║╚══██╔══╝██╔══██╗██║░██╔╝██╔════╝████╗░██║
███████║███████║██║░░░░░██████╦╝██║░░██║██████╔╝██╔██╗██║░░░██║░░░██║░░██║█████═╝░█████╗░░██╔██╗██║
██╔══██║██╔══██║██║░░░░░██╔══██╗██║░░██║██╔══██╗██║╚████║░░░██║░░░██║░░██║██╔═██╗░██╔══╝░░██║╚████║
██║░░██║██║░░██║███████╗██████╦╝╚█████╔╝██║░░██║██║░╚███║░░░██║░░░╚█████╔╝██║░╚██╗███████╗██║░╚███║
╚═╝░░╚═╝╚═╝░░╚═╝╚══════╝╚═════╝░░╚════╝░╚═╝░░╚═╝╚═╝░░╚══╝░░░╚═╝░░░░╚════╝░╚═╝░░╚═╝╚══════╝╚═╝░░╚══╝
15/04/2022
Halborn ERC20 token contract
Flow:
1. Our CISO Steve will deploy the contract minting to his wallet 10000 Halborn Tokens
2. Steve will transfer 100 Halborn tokens to each employee
3. Gabi, our Director of Offensive Security Engineering, will ask to each of the employees to lock the tokens in the contract 
by calling the newTimeLock() function with the following parameters:
    a. timelockedTokens_ -> 100_000000000000000000 (The 100 tokens)
    b. vestTime_ -> The vestTime will be the current block.timestamp (now)
    c. cliffTime_ -> The cliffTime should be 6 months
    d. disbursementPeriod_ -> The disbursementPeriod should be 1 year
We can not wait to use these tokens but we always audit everything before a deployment
Maybe can you give us a hand with this task? 
Although... hacking a Halborn's hacker contract? Not gonna happen

____________ my notes on the basics of cliff vesting: _________________

- Vesting period is the period during which tokens are being released proportionally. (starts now)
- However, there is Cliff Time - it is a point in the future, when first tokens become transferable.
- Disbursement period is one year from the start of the vesting? or from the cliff?
_________________________________________________________________________________
                                    
                                    
                                    
                                    
                                 >|
                            >     |
                      >           |
                > Vesting         | 
                                  | 
                                  | Disbursement IS over here. 
________________| Cliff Time_____ |_______________________________________________
1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16 17 18
__________________________________________________________________________________


*/

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract HalbornToken is ERC20 {
    // token locking state variables
    mapping(address => uint256) public disbursementPeriod;
    mapping(address => uint256) public vestTime;
    mapping(address => uint256) public cliffTime;
    mapping(address => uint256) public timelockedTokens;
    address private signer;
    bytes32 private root;

    /**
     * @dev Emitted when the token lockup is initialized
     * `tokenHolder` is the address the lock pertains to
     *  `amountLocked` is the amount of tokens locked
     *  `vestTime` unix time when tokens will start vesting
     *  `cliffTime` unix time before which locked tokens are not transferrable
     *  `period` is the time interval over which tokens vest
     */
    event NewTokenLock(
        address tokenHolder,
        uint256 amountLocked,
        uint256 vestTime,
        uint256 cliffTime,
        uint256 period
    );

    constructor(
        string memory name_, // name      - Halborn Token
        string memory symbol_, // symbol    - HT
        uint256 amount_, // amount    - 10 000
        address deployer_, // deployer_ - Steve's account
        bytes32 _root // _root     - place the MerkleRoot here (whitelist of accounts who have a permission to mint)
    ) ERC20(name_, symbol_) {
        _mint(deployer_, amount_); // create amount_ tokens and assign them to deployer_ address
        signer = deployer_; // signer is the role for minting tokens
        root = _root; // Assigning the root hash of the merkle tree to the variable
    }

    /* 
     @dev function to lock tokens, only if there are no tokens currently locked
     @param timelockedTokens_ number of tokens to lock up
     @param `vestTime_` unix time when tokens will start vesting
     @param `cliffTime_` unix time before which locked tokens are not transferrable
     @param `disbursementPeriod_` is the time interval over which tokens vest
     */
    function newTimeLock(
        uint256 timelockedTokens_, // 100
        uint256 vestTime_, // block.timestamp + 1 sec
        uint256 cliffTime_, // block.timestamp + 6 months
        uint256 disbursementPeriod_ // 1 year Epoch
    ) public {
        // read the comments first, and understand what is it meant to do, than go to the code
        // for lock tokens here are the conditions which should be met
        require(timelockedTokens_ > 0, "Cannot timelock 0 tokens");
        require(
            timelockedTokens_ <= balanceOf(msg.sender),
            "Cannot timelock more tokens than current balance"
        );
        require(
            // check this function. Maybe i can break this require clause
            // possible impact is locking more tokens than one has
            balanceLocked(msg.sender) == 0,
            "Cannot timelock additional tokens while tokens already locked"
        );
        require(
            disbursementPeriod_ > 0,
            "Cannot have disbursement period of 0"
        );
        require(
            vestTime_ > block.timestamp,
            "vesting start must be in the future"
        );
        require(
            cliffTime_ >= vestTime_,
            "cliff must be at same time as vesting starts (or later)"
        );

        disbursementPeriod[msg.sender] = disbursementPeriod_;
        vestTime[msg.sender] = vestTime_;
        cliffTime[msg.sender] = cliffTime_;
        timelockedTokens[msg.sender] = timelockedTokens_;
        emit NewTokenLock(
            msg.sender,
            timelockedTokens_,
            vestTime_,
            cliffTime_,
            disbursementPeriod_
        );
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     */
    // this one is inherited from erc20 openZ and is being overriden (OpenZ docs are asking to call super everytime! here they do not call super...) )
    // can i pass arguments here?
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        // accessible only via contract and derivatives (it overrides function and is letting overriding)
        uint256 maxTokens = calcMaxTransferrable(from);
        // this is the flow:
        // calculate maxtokens in any case. And go further into "transfering" OR minting, or burning...
        // IF 'from' address IS VALID ADDRESS & amount MORE THAN maxTokens  ---THEN--->>> revert (throw exception)
        if (from != address(0x0) && amount > maxTokens) {
            revert("amount exceeds available unlocked tokens");
        } // but what IF 'from' IS zero AND|OR amount < maxTokens ---THEN--->>> go further! (every combination is letting us further)
    }

    /// @dev Calculates the maximum amount of transferrable tokens for address `who`
    /// @return Number of transferrable tokens
    function calcMaxTransferrable(address who) public view returns (uint256) {
        // if there is no locked tokens return the whole balance
        if (timelockedTokens[who] == 0) {
            return balanceOf(who);
        }
        uint256 maxTokens;
        if (
            // THIS CLAUSE SAYS: if vesttime, or clifftime is in the future
            // --> there are no tokens to transfer
            vestTime[who] > block.timestamp || cliffTime[who] > block.timestamp
            //                                       ^ here is how they are restricting me to transfer before the cliff
        ) {
            maxTokens = 0;
            // THIS CLAUSE SAYS: if vesttime AND clifftime are <= block.timestamp
            // --> locked tokens * (now - vest) / period
        } else {
            maxTokens =
                // locked tokens = 90, vest = 01.12.21, now = 01.06.22, period = 1 year
                // MATH EXAMPLE: 90 * (1654077600 - 1638356400) / 31536000 = 44.86643 (without precision it is 44)
                (timelockedTokens[who] * (block.timestamp - vestTime[who])) /
                disbursementPeriod[who];
            // now we have calculated max tokens (did we try every combination? YES) and saved it to variable
        }
        // this is (true) if the period has already passed --> return the whole balance
        // now = 01.02.23, vest = 01.12.21, period = 1 year
        // MATH EXAMPLE: 90 * (1675249200 - 1638356400) / 31536000 = 105.28...
        if (timelockedTokens[who] < maxTokens) {
            return balanceOf(who);
        }

        return balanceOf(who) - timelockedTokens[who] + maxTokens;
    }

    /// @dev Calculates the amount of locked tokens for address `who`
    function balanceLocked(address who) public view returns (uint256 amount) {
        // IT SAYS: If there is no locked tokens
        // --> return 0
        if (timelockedTokens[who] == 0) {
            // it returns uint number? or it can be treated as successfull execution as in 'C'? Check this manually
            return 0;
        }
        if (
            // if vest OR cliff is in the future
            // --> return all locked Tokens
            vestTime[who] > block.timestamp || cliffTime[who] > block.timestamp
        ) {
            return timelockedTokens[who];
        }
        // max = (locked tokens * (now - vest) / period)
        // locked tokens = 90, vest = 01.12.21, now = 01.06.22, period = 1 year
        // MATH EXAMPLE: 90 * (1654077600 - 1638356400) / 31536000 = 44.86643 (without precision it is 44)
        uint256 maxTokens = (timelockedTokens[who] *
            (block.timestamp - vestTime[who])) / disbursementPeriod[who];
        // if max >= locked tokens --> return 0
        // IT SAYS: if there are more transferable tokens than actually are locked, RETURN 0;
        if (maxTokens >= timelockedTokens[who]) {
            return 0;
        }
        // IT SAYS: balanceLocked = locked tokens - max
        // MY EXAMPLE: 90 - 44 = 46
        return timelockedTokens[who] - maxTokens;
    }

    /// @dev Calculates the maximum amount of transferrable tokens for address `who`. Alias for calcMaxTransferrable for backwards compatibility.
    function balanceUnlocked(address who) public view returns (uint256 amount) {
        return calcMaxTransferrable(who);
    }

    /// @dev Sets a new signer account. Only the current signer can call this function
    function setSigner(address _newSigner) public {
        // this is weird. are they checking for msg.sender IS whoever but not the current deployer?
        require(msg.sender != signer, "You are not the current signer");
        signer = _newSigner;
    }

    /// @dev Used in case we decide totalSupply must be increased
    // this one is the vulnerability number 1 - i can mint tokens using any account
    function mintTokensWithSignature(
        uint256 amount,
        bytes32 _r,
        bytes32 _s,
        uint8 _v
    ) public {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 messageHash = keccak256(
            abi.encode(address(this), amount, msg.sender)
        );
        bytes32 hashToCheck = keccak256(abi.encodePacked(prefix, messageHash));
        require(
            // HERE. the signer is responsible for extra minting
            signer == ecrecover(hashToCheck, _v, _r, _s),
            "Wrong signature"
        );
        _mint(msg.sender, amount);
    }

    /// @dev Used only by whitelisted users. The MerkleRoot is set in the constructor
    // looks like i can send arbitrary root and proof (valid for the case of my leaf)
    // Which should bypass the require clause
    function mintTokensWithWhitelist(
        uint256 amount,
        bytes32 _root,
        bytes32[] memory _proof
    ) public {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(verify(leaf, _root, _proof), "You are not whitelisted.");
        _mint(msg.sender, amount);
    }

    // why did not use merkleproof.sol from OpenZeppelin? TO INCLUDE ROOT AS ARGUMENT :))
    // it seems, nothing stops me from calling this function with a valid leaf, proof and root (not related to root of the contract)
    // and it should work
    // how should i build proof array?
    function verify(
        bytes32 leaf,
        bytes32 _root,
        bytes32[] memory proof
    ) public view returns (bool) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = keccak256(
                    abi.encodePacked(computedHash, proofElement)
                );
            } else {
                computedHash = keccak256(
                    abi.encodePacked(proofElement, computedHash)
                );
            }
        }
        return computedHash == _root;
    }
}
//                  Merkle Tree
//           [R]                R           = root                  [R]
//    [p1]         [p2]         p1, p2      = parents           [l]     [s]
// [s]    [l]   [ ]    [ ]      l = leaf, s = sibling       this should be enough, because:
//                                                          hash(hash(l), hash(s)) = root

// 1. exploit mint from signer!                                                                                 DONE
// 2. understand the way verify is implemented - this should be the second vulnerability                        DONE
// 3. no nonce in the mintWithSignature / maybe this might lead to replay attacks...                            ----
// 4. if balanceLocked is vulnerable I might be able to break the require statement in timeLock function
// 4. maybe i can cause over/underflow with uint/int downcasting?
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeCast.sol
// 5. try the application as intended. what results do i have? try most common cases as well as weird ones.
