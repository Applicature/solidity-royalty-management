pragma solidity ^0.4.24;

contract IManagement {


    /**
      * @dev sets or unset permissions to make some actions
      * @param _address address Address which  is allowed/disalwed to run function
      * @param _permission uint256 constant value describes one of the permission
      * @param _value bool sets/unsets _permission
    */
    function setPermission(
        address _address,
        uint256 _permission,
        bool _value
    )
        public;

    /**
     * @dev register contract with ID
     * @param _key uint256 constant value, indicates the contract
     * @param _target address Address of the contract
   */
    function registerContract(uint256 _key, address _target) public;

    /**
     * @dev sets registration fee
     * @param _newAssetRegistrationPrice uint256 fee amout which  should receive Platform for the registration
    */
    function setAssetRegistrationPrice(
        uint256 _newAssetRegistrationPrice
    )
        public;

    /**
     * @dev sets platform  revenue receiver address
     * @param _newAddress address platform related address to receive ethers
    */
    function updatePlatformHolderAddress(address _newAddress)
        public;

    /**
     * @dev sets percents revenue for platform per each license purchase
     * @param _platformRevenueInPercents uint256 part of the price in percents  the platform  are going to receive
     * @param _percentAbsMax uint256 absolute percent value
    */
    function updatePlatformPercentsRevenue(
        uint256 _platformRevenueInPercents,
        uint256 _percentAbsMax
    )
        public;

    /**
     * @dev updates period of signed transaction data live
     * @param _transactionDataExpirationPeriod uint256 duration in seconds
    */
    function setTransactionDataExpirationPeriod(
        uint256 _transactionDataExpirationPeriod
    )
        public;

    /**
        * @dev checks if address is  a contact
        * @param _address address requested address
        * @return true in case when address is a contract
    */
    function isContract(address _address) public view returns (bool);

    /**
       * @dev returns max absolute percent value
   */
    function percentAbsMax() public view returns (uint256);

    /**
      * @dev returns platform revenue in percents per each license purchase
    */
    function platformRevenueInPercents() public view returns (uint256);

    /**
      * @dev returns platform holder address
    */
    function platformHolderAddress() public view returns (address);

    function contractRegistry(uint256 _contractId) public view returns (address);

    function assetRegistrationPrice() public view returns (uint256);

    function transactionDataExpirationPeriod() public view returns (uint256);

    function permissions(address _subject, uint256 _permissionBit)
        public
        view
        returns (bool);
}
