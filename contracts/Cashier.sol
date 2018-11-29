pragma solidity 0.4.24;

import "./Managed.sol";
import "./Royalty.sol";


contract Cashier is Managed {

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
        Management managementContract = Management(management);
        uint256 platformProfit = msg.value
            .mul(managementContract.platformRevenueInPercents())
            .div(managementContract.percentAbsMax());
        managementContract.platformHolderAddress().transfer(platformProfit);
        Royalty royalty = Royalty(
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
            Management(management).platformHolderAddress().transfer(msg.value);
        }
    }
}
