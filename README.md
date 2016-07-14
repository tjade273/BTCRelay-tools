# BTCRelay-Solidity Tools
Tools for interacting with the BTC Relay in Solidity

This contract provides an interface with BTC Relay which accepts and returns intuitive Solidity types, and provides additional functionality like fetching block headers by block height and caching results in a manner that is fair to the original relayers.

Contract Address:

ABI:

# API
----

## Transaction Verification

### verifyTx(rawTransaction, transactionIndex, merkleSibling, blockHash)

Verifies the presence of a transaction on the Bitcoin blockchain, primarily that the transaction is on Bitcoin's main chain and has at least 6 confirmations.

**Arguments:**
* `rawTransaction: bytes` - raw bytes of the transaction
* `transactionIndex: uint256` - transaction's index within the block
* `merkleSibling: bytes32[]` - array of the sibling hashes comprising the Merkle proof
* `blockHash: bytes32` - hash of the block that contains the transaction

**Returns:** `uint256`
* hash of the verified Bitcoin transaction
* 0 if rawTransaction is exactly 64 bytes in length or fails verification

### relayTx(rawTransaction, transactionIndex, merkleSibling, blockHash, contractAddress)

Verifies a Bitcoin transaction per `verifyTx()` and relays the verified transaction to the specified Ethereum contract.

**Arguments:**
* `rawTransaction: bytes` - raw bytes of the transaction
* `transactionIndex: uint256` - transaction's index within the block
* `merkleSibling: bytes32[]` - array of the sibling hashes comprising the Merkle proof
* `blockHash: bytes32` - hash of the block that contains the transaction
* `contractAddress: address` - address of the processor contract that will receive the verified Bitcoin transaction

The processor contract at contractAddress should have a function of signature `processTransaction(bytes rawTransaction, uint256 transactionHash) returns (int256)` and is what will be invoked by relayTx if the transaction passes verification. For examples, see BitcoinProcessor.sol and testnetSampleRelayTx.html.

**Returns:** `int256`
* value returned by the processor contract's processTransaction function
or _-1_ on failure

_Note: Callers cannot be 100% certain when an relay error occurs because_ -1  _may also have been returned by processTransaction(). Callers should be aware of the contract that they are relaying transactions to, and understand what the processor contract's processTransaction method returns._

--------------------------------------------------------------------------------

## Block Lookup

### getBlockHash(blockHeight)

Get the block hash for a given blockHeight.

**Arguments:**
* `blockHeight: uint256` - height of the block. Minimum value is 1.

**Returns:** `(bytes32, uint256)`
* (block hash, total fee paid)
* (0, total fee paid) if not found or insufficient fee

*NOTE:  Due to the mechanics of BTC Relay, in order to fetch a block hash we must iterate over all of the successive blocks in the chain, paying the required fee for each. This is only true the first time a given block header is fetched, so before calling this function make sure to call `getFeeAmount()` and check if you are willing to pay the current price.*


### getBlockHeight(blockHash)

Get the block height of a block by its hash

**Arguments:**
* `blockHash: bytes32` - block hash of a Bitcoin block

**Returns:** `uint`
* Height of the block
* 0 if not found

--------------------------------------------------------------------------------

## Block Header Fields

You must pay a small fee for these, i.e.

    uint fee = relay.getFeeAmount(blockHash);
    bytes32 merkleRoot = relay.getMerkleRoot.value(fee)(blockHash);

### getBlockVersion(blockHash)

Get the Bitcoin block version bytes

**Arguments:**
* `blockHash: bytes32` - BTC block hash

**Returns:** `bytes4`
* 4-byte BTC block version indicator
* 0 if not found

### getParentHash(blockHash)

Get the hash of the block immediately previous

**Arguments:**
* `blockHash: bytes32` - BTC block hash

**Returns:** `bytes32`
* Blockhash of the parent block
* 0 if not found

### getMerkleRoot(blockHash)

Get the Merkle root for the block

**Arguments:**
* `blockHash: bytes32` - BTC block hash

**Returns:** `bytes32`
* Merkle root of the block
* 0 if not found

### getTimestamp(blockHash)

Get the timestamp of the block, as a `bytes4`

**Arguments:**
* `blockHash: bytes32` - BTC block hash

**Returns:** `bytes4`
* Timestamp of the block
* 0 if not found

### getBits(blockHash)

Get the abbreviated difficulty
- Actual difficulty is calculated as `bits * 2**(8*(0x1b - 3))`

**Arguments:**
* `blockHash: bytes32` - BTC block hash

**Returns:** `bytes4`
* Bits field of the block
* 0 if not found

### getNonce(blockHash)

Get the nonce of the block

**Arguments:**
* `blockHash: bytes32` - BTC block hash

**Returns:** `bytes4`
* Nonce field of the block
* 0 if not found
