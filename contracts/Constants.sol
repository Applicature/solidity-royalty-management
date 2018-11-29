pragma solidity 0.4.24;


contract Constants {

    // Permissions bit constants
    uint256 public constant CAN_RECORD_PURCHASE = 0;
    uint256 public constant CAN_SIGN_TRANSACTION = 1;

    // Contract Registry keys
    uint256 public constant CONTRACT_CASHIER = 1;
    uint256 public constant CONTRACT_ROYALTY = 2;
    uint256 public constant CONTRACT_ASSET_PURCHASE = 3;

    string public constant ERROR_ACCESS_DENIED = 'ERROR_ACCESS_DENIED';
    string public constant ERROR_WRONG_AMOUNT = 'ERROR_WRONG_AMOUNT';
    string public constant ERROR_NO_CONTRACT = 'ERROR_NO_CONTRACT';
    string public constant ERROR_NOT_AVAILABLE = 'ERROR_NOT_AVAILABLE';
}