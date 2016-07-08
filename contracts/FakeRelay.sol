import "./BTCRelay.sol";
contract FakeRelay is BTCRelay{
    bytes head;
    function FakeRelay(bytes header){
        head = header;
    }

    function getBlockHeader(int) returns (bytes){
        return head;
    }

}
