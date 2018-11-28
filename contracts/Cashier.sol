pragma solidity 0.4.24;

import './Managed.sol';
import './Royalty.sol';


contract Cashier is Managed {

    address public platformHolder;
    uint256 public platformRevenueInPercents;
    uint256 public percentAbsMax;

    constructor(
        address _management,
        address _platformHolder,
        uint256 _platformRevenueInPercents,
        uint256 _percentAbsMax
    )
        public Managed(_management)
    {
        require(_platformHolder != address(0), ERROR_ACCESS_DENIED);
        require(isContract(_platformHolder) == false, ERROR_ACCESS_DENIED);
        platformHolder = _platformHolder;
        platformRevenueInPercents = _platformRevenueInPercents;
        percentAbsMax = _percentAbsMax;
    }

    function recordPurchase(
        uint256 _digitalAssetId
    )
        public
        payable
        requirePermission(CAN_RECORD_PURCHASE)
        canCallOnlyRegisteredContract(CONTRACT_ROYALTY)
        returns (uint256)
    {
        platformHolder.transfer(
            msg.value
            .mul(platformRevenueInPercents)
            .div(percentAbsMax)
        );
        Royalty royalty = Royalty(management.contractRegistry(CONTRACT_ROYALTY));
        royalty.ownerOf(_digitalAssetId).transfer(msg.value);
    }

    function updatePlatformHolderAddress(address _newAddress)
        public
        onlyOwner
    {
        platformHolder = _newAddress;
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
        platformRevenueInPercents = _platformRevenueInPercents;
        percentAbsMax = _percentAbsMax;
    }
}