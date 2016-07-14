contract BTCRelay {
    function getBlockHeader(int blockHash) returns (bytes32[5]); //Call manually?
    function getLastBlockHeight() returns (int);
    function getBlockchainHead() returns (int);
    function getFeeAmount(int blockHash) returns (int);
    function getFeeRecipient(int blockhash) returns (int);
    function getChangeRecipientFee() returns (int);
    function changeFeeRecipient(int blockHash, int fee, int recipient);
    function verifyTx(bytes, int, bytes32[], int) returns (int);
}
