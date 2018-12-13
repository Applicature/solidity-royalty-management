pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Constants.sol";
import "./interfaces/IManagement.sol";


contract Management is Ownable, Constants, IManagement {

    // Contract Registry
    mapping(uint256 => address) public contractRegistry;

    uint256 public transactionDataExpirationPeriod = 1 hours;
    uint256 public assetRegistrationPrice = 0.005 ether;
    address public platformHolderAddress;
    uint256 public platformRevenueInPercents;
    uint256 public percentAbsMax;

    // Permissions
    mapping(address => mapping(uint256 => bool)) public permissions;

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
        platformHolderAddress = _platformHolderAddress;
        platformRevenueInPercents = _platformRevenueInPercents;
        percentAbsMax = _percentAbsMax;
    }

    function setPermission(
        address _address,
        uint256 _permission,
        bool _value
    )
        public
        onlyOwner
    {
        permissions[_address][_permission] = _value;

        emit PermissionsSet(_address, _permission, _value);
    }

    function registerContract(uint256 _key, address _target) public onlyOwner {
        contractRegistry[_key] = _target;

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
        assetRegistrationPrice = _newAssetRegistrationPrice;
    }

    function updatePlatformHolderAddress(address _newAddress)
        public
        onlyOwner
    {
        require(
            _newAddress != address(0),
            ERROR_ZERO_ADDRESS
        );
        platformHolderAddress = _newAddress;
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
        platformRevenueInPercents = _platformRevenueInPercents;
        percentAbsMax = _percentAbsMax;
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
        transactionDataExpirationPeriod = _transactionDataExpirationPeriod;
    }

    function isContract(address _addr) public view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

}
