pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Constants.sol";
import "./interfaces/IManagement.sol";


contract Management is Ownable, Constants, IManagement {

    uint256 private percentAbsMax_;
    uint256 private platformRevenueInPercents_;
    address private platformHolderAddress_;
    uint256 private assetRegistrationPrice_ = 0.005 ether;
    uint256 private transactionDataExpirationPeriod_ = 1 hours;

    mapping(uint256 => address) private contractRegistry_;
    mapping(address => mapping(uint256 => bool)) public permissions_;

    event PermissionsSet(address subject, uint256 permission, bool value);

    event ContractRegistered(uint256 key, address target);

    constructor(
        address _platformHolderAddress,
        uint256 _platformRevenueInPercents,
        uint256 _percentAbsMax
    )
        public
    {
        require(
            _platformHolderAddress != address(0),
            ERROR_ZERO_ADDRESS
        );
        require(
            isContract(_platformHolderAddress) == false,
            ERROR_ACCESS_DENIED
        );
        platformHolderAddress_ = _platformHolderAddress;
        platformRevenueInPercents_ = _platformRevenueInPercents;
        percentAbsMax_ = _percentAbsMax;
    }

    function setPermission(
        address _address,
        uint256 _permission,
        bool _value
    )
        public
        onlyOwner
    {
        permissions_[_address][_permission] = _value;

        emit PermissionsSet(_address, _permission, _value);
    }

    function registerContract(uint256 _key, address _target) public onlyOwner {
        contractRegistry_[_key] = _target;

        emit ContractRegistered(_key, _target);
    }

    function setAssetRegistrationPrice(
        uint256 _newAssetRegistrationPrice
    )
        public
        onlyOwner
    {
        require(
            _newAssetRegistrationPrice >= 0,
            ERROR_NOT_AVAILABLE
        );
        assetRegistrationPrice_ = _newAssetRegistrationPrice;
    }

    function updatePlatformHolderAddress(address _newAddress)
        public
        onlyOwner
    {
        require(
            _newAddress != address(0),
            ERROR_ZERO_ADDRESS
        );
        platformHolderAddress_ = _newAddress;
    }

    function updatePlatformPercentsRevenue(
        uint256 _platformRevenueInPercents,
        uint256 _percentAbsMax
    )
        public
        onlyOwner
    {
        require(
            _platformRevenueInPercents < _percentAbsMax,
            ERROR_WRONG_AMOUNT
        );
        require(
            _percentAbsMax >= 100 &&
            _percentAbsMax % 100 == 0,
            ERROR_WRONG_AMOUNT
        );
        platformRevenueInPercents_ = _platformRevenueInPercents;
        percentAbsMax_ = _percentAbsMax;
    }

    function setTransactionDataExpirationPeriod(
        uint256 _transactionDataExpirationPeriod
    )
        public
        onlyOwner
    {
        // 0 -  means no limit for transaction data expiration
        require(
            _transactionDataExpirationPeriod >= 0,
            ERROR_NOT_AVAILABLE
        );
        transactionDataExpirationPeriod_ = _transactionDataExpirationPeriod;
    }

    function isContract(address _addr) public view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function percentAbsMax() public view returns (uint256) {
        return percentAbsMax_;
    }

    function platformRevenueInPercents() public view returns (uint256) {
        return platformRevenueInPercents_;
    }

    function platformHolderAddress() public view returns (address) {
        return platformHolderAddress_;
    }

    function contractRegistry(uint256 _contractId)
        public view returns (address)
    {
        return contractRegistry_[_contractId];
    }

    function assetRegistrationPrice() public view returns (uint256) {
        return assetRegistrationPrice_;
    }

    function transactionDataExpirationPeriod() public view returns (uint256) {
        return transactionDataExpirationPeriod_;
    }

    function permissions(address _subject, uint256 _permissionBit)
        public
        view
        returns (bool)
    {
        return permissions_[_subject][_permissionBit];
    }
}
