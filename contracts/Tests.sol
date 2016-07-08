import 'dapple/test.sol';
import "./FakeRelay.sol";
import "./BTCRelayTools.sol";

contract RelayToolsTest is Test {
  FakeRelay fake;
  Tester proxy;
  BTCRelayTools tools;
  uint fee;

  bytes header;
  uint8[80] head = [0x01,  0x00,  0x00,  0x20,  0x53,  0x09,  0x63,  0xc9,  0x6f,  0x62,  0x07,  0xfc,  0x24,  0x24,  0x8b,  0x5d,
                  0xa2,  0x31,  0x56,  0x2e,  0x48,  0x50,  0x8f,  0xfc,  0xb5,  0xb6,  0xef,  0x02,  0x00,  0x00,  0x00,  0x00,
                  0x00,  0x00,  0x00,  0x00,  0x7c,  0x55,  0x3f,  0xd5,  0x82,  0x8d,  0x21,  0xba,  0x67,  0x14,  0x0a,  0x8c,
                  0xde,  0x51,  0xe6,  0xe5,  0x15,  0xb7,  0xae,  0x73,  0x3f,  0xa4,  0x0a,  0x6d,  0x08,  0xd7,  0xaf,  0xf1,
                  0x7c,  0x44,  0xd4,  0x93,  0xd1,  0x12,  0x6b,  0x57,  0xd6,  0x3f,  0x05,  0x18,  0x2e,  0x3a,  0x9e,  0x6f ];

  function RelayToolsTest(){
    for(uint i = 0; i<80; i++){
      header.push(byte(head[i]));
    }
  }

  function setUp() {

    fake = new FakeRelay(header);
    tools = new BTCRelayTools(fake);
    proxy = new Tester();
    proxy._target(tools);
    fee = uint(fake.getFeeAmount(0));

  }

  function testBlockHashFetch(){
    bytes32 blockHash;
    (blockHash,) = tools.getBlockHash.value(1000)(95);
    bytes32 correctHash = 0x000000000000000002efb6b5fc8f50482e5631a25d8b2424fc07626fc9630953;

    assertTrue(blockHash == correctHash, blockHash);
  }

  function testBlockHeaderFetch() {

    bytes32 blockHash;
    (blockHash,) = tools.getBlockHash.value(1000)(95);

    bytes4 correctVersion = 0x20000001;
    bytes4 version = tools.getBlockVersion.value(fee)(blockHash);
    assertTrue(version == correctVersion, version);

    bytes32 correctParentHash = 0x000000000000000002efb6b5fc8f50482e5631a25d8b2424fc07626fc9630953;
    bytes32 parentHash = tools.getParentHash.value(fee)(blockHash);
    assertTrue(parentHash == correctParentHash, parentHash);

    bytes32 correctMerkleRoot = 0x93d4447cf1afd7086d0aa43f73aeb715e5e651de8c0a1467ba218d82d53f557c;
    bytes32 merkleRoot = tools.getMerkleRoot.value(fee)(blockHash);
    assertTrue(merkleRoot == correctMerkleRoot, merkleRoot);

    bytes4 correctTimestamp = 0x576b12d1;
    bytes4 timestamp = tools.getTimestamp.value(fee)(blockHash);
    assertTrue(timestamp == correctTimestamp, timestamp);

    bytes4 correctBits = 0x18053fd6;
    bytes4 bits = tools.getBits.value(fee)(blockHash);
    assertTrue(bits == correctBits, bits);

    bytes4 correctNonce = 0x6f9e3a2e;
    bytes4 nonce = tools.getNonce.value(fee)(blockHash);
    assertTrue(nonce == correctNonce, nonce);
  }

  function testBalance(){
    assertTrue(this.balance > 50, bytes32(this.balance / 1 wei));
  }

  function testFailHeaderInsufficientFee(){
    bytes4 version = tools.getBlockVersion.value(fee/2)(0);
  }

  function testFailBlockhashInsuffiecientFee(){
    tools.getBlockHash.value(fee*5-1)(95);
  }

  function testBlockhashCorrectFee(){
    tools.getBlockHash.value(fee*5)(95);
  }

}
