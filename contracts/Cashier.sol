pragma solidity 0.4.24;

import "./Managed.sol";
import "./interfaces/IRoyalty.sol";
import "./interfaces/ICashier.sol";


contract Cashier is Managed, ICashier {

    constructor(address _management) public Managed(_management){}

    function recordPurchase(
        uint256 _digitalAssetId
    )
        public
        payable
        requirePermission(CAN_RECORD_PURCHASE)
        requireContractExistsInRegistry(CONTRACT_ROYALTY)
        canCallOnlyRegisteredContract(CONTRACT_ASSET_PURCHASE)
    {
        IManagement managementContract = IManagement(management);
        uint256 platformProfit = msg.value
            .mul(managementContract.platformRevenueInPercents())
            .div(managementContract.percentAbsMax());
        managementContract.platformHolderAddress().transfer(platformProfit);
        IRoyalty royalty = IRoyalty(
            managementContract.contractRegistry(CONTRACT_ROYALTY)
        );
        royalty.ownerOf(_digitalAssetId).transfer(
            msg.value.sub(platformProfit)
        );
    }

    function forwardEthersToHolder()
        public
        payable
        requirePermission(CAN_RECORD_PURCHASE)
        requireContractExistsInRegistry(CONTRACT_ROYALTY)
        canCallOnlyRegisteredContract(CONTRACT_ROYALTY)
    {
        if (msg.value > 0) {
            IManagement(management).platformHolderAddress().transfer(msg.value);
        }
    }
}
