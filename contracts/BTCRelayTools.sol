import "./FakeRelay.sol";
import "./BTCRelay.sol";

contract BTCRelayTools {
    BTCRelay public relay;

    struct BlockHeader {
        //Identifying info
        uint blockHeight;

        //Header conents
        bytes4 version;
        bytes32 parentHash;
        bytes32 merkleRoot;
        bytes4 timestamp;
        bytes4 bits;
        bytes4 nonce;
    }

    mapping(bytes32 => BlockHeader) private blockHeaders;
    mapping(uint => bytes32) public blockHashes;

    uint[6] indecies = [0x40,0x44,0x64,0x84, 0x88, 0x8c]; //Offsets of each field

    function BTCRelayTools(address _relay){
        relay = BTCRelay(_relay);
    }


    function parseHeaderFields(BlockHeader storage self, bytes32[5] header) internal {

        self.version = get4(header, indecies[0]);
        self.parentHash = get32(header, indecies[1]);
        self.merkleRoot = get32(header, indecies[2]);
        self.timestamp = get4(header, indecies[3]);
        self.bits = get4(header, indecies[4]);
        self.nonce = get4(header, indecies[5]);
    }

    function parseBlock(bytes32 blockHash, uint blockHeight) internal returns (uint fee) {

        fee = uint(relay.getFeeAmount(int(blockHash)));

        if(blockHashes[blockHeight] ==0){
            bytes32[5] memory blockHeader = relay.getBlockHeader.value(fee)(int(blockHash));

            blockHashes[blockHeight] = blockHash;
            BlockHeader h = blockHeaders[blockHash];

            h.blockHeight = blockHeight;
            parseHeaderFields(h, blockHeader);
        }

        else{
            //payFee(blockHash);  //Decide whether people should pay fees for already collected blocks...
            return 0;
        }
    }

    function getBlockHash (uint blockHeight) constant returns (bytes32, uint totalFee){ //Get blockhash of given blocknum
        if(blockHashes[blockHeight] == 0){
          uint highestBlock = uint(relay.getLastBlockHeight());
          bytes32 currentHash = bytes32(relay.getBlockchainHead());
          if(blockHeight > highestBlock) throw;

          for(uint i = highestBlock; i > blockHeight; i--){
            if(currentHash == 0) return (0x0,totalFee);
            totalFee += parseBlock(currentHash, i);
            currentHash = blockHeaders[currentHash].parentHash;
          }

          if(totalFee > msg.value) throw;
          return (blockHeaders[currentHash].parentHash, totalFee);
        }
        else {
          payFee(blockHashes[blockHeight]);
          return blockHashes[blockHeight];
        }
    }

    function getBlockHeight(bytes32 blockHash) returns (uint){
        payFee(blockHash);
        return blockHeaders[blockHash].blockHeight;
    }

    function getBlockVersion(bytes32 blockHash) returns (bytes4) {
        payFee(blockHash);
        return blockHeaders[blockHash].version;
    }

    function getParentHash(bytes32 blockHash) returns (bytes32) {
        payFee(blockHash);
        return blockHeaders[blockHash].parentHash;
    }

    function getMerkleRoot(bytes32 blockHash) returns (bytes32) {
        payFee(blockHash);
        return blockHeaders[blockHash].merkleRoot;
    }

    function getTimestamp(bytes32 blockHash) returns (bytes4) {
        payFee(blockHash);
        return blockHeaders[blockHash].timestamp;
    }

    function getBits(bytes32 blockHash) returns (bytes4) {
        payFee(blockHash);
        return blockHeaders[blockHash].bits;
    }

    function getNonce(bytes32 blockHash) returns (bytes4) {
        payFee(blockHash);
        return blockHeaders[blockHash].nonce;
    }


    //Utilities

    function payFee(bytes32 blockHash) private {
        uint fee = uint(relay.getFeeAmount(int(blockHash)));
        address recipient = address(relay.getFeeRecipient(int(blockHash)));

        if(fee > msg.value) throw;
        recipient.send(fee); //If the fee doesn't go through, oh well....
    }

    function getParentHash(bytes32[5] header) internal returns (bytes32 parentHash){
        parentHash = get32(header, indecies[1]);
    }


    function get32(bytes32[5] header, uint index) constant returns (bytes32 out){
        assembly {
            out := mload(add(header,index))
        }

        out = flip32(out);
    }

    function get4(bytes32[5] header, uint index) constant returns (bytes4 out){
        assembly {
            out := mload(add(header,index))
        }

        out = flip4(out);
    }


    function flip32(bytes32 data) constant returns (bytes32 out){
        for(uint i; i<32; i++){
            out = out | bytes32(uint(data[i]) * (0x100**i));
        }
    }

    function flip4(bytes4 data) constant returns (bytes4 out) {
        for(uint i; i<4; i++){
            out = out | bytes4(uint(data[i]) * (0x100**i));
        }
    }


}
