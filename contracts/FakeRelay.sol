contract FakeRelay{
    bytes head;
    function FakeRelay(bytes header){
        head = header;
    }

    function getBlockHeader(int) returns (bytes){
        return head;
    }

    function getFeeRecipient(int) returns (int) {
        return 0xabcdef;
    }

    function getFeeAmount(int) returns (int) {
      return 10;
    }

    function getBlockchainHead() returns (int){
      return 0xabcd;
    }

    function getLastBlockHeight() returns (int) {
      return 100;
    }

}
