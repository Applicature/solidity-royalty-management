pragma solidity 0.4.24;

import "./Managed.sol";
import "./Royalty.sol";
import "./Cashier.sol";


contract AssetPurchase is Managed {

    event AssetUsagePurchased(
        uint256 indexed digitalAssetId,
        address indexed buyer,
        uint256 amount,
        uint256 purchasingTimestamp
    );

    constructor(address _management) public Managed(_management) {
    }

    function purchaseDigitalAsset(
        uint256 _digitalAssetId
    )
        public
        payable
        requireContractExistsInRegistry(CONTRACT_CASHIER)
    {
        Royalty royaltyContract = Royalty(
            management.contractRegistry(CONTRACT_ROYALTY)
        );
        require(
            royaltyContract.getEtherPriceForAsset(_digitalAssetId) == msg.value,
            ERROR_WRONG_AMOUNT
        );
        require(royaltyContract.exists(_digitalAssetId), ERROR_NOT_AVAILABLE);

        Cashier cashier = Cashier(
            management.contractRegistry(CONTRACT_CASHIER)
        );
        cashier.recordPurchase.value(msg.value)(_digitalAssetId);

        emit AssetUsagePurchased(
            _digitalAssetId,
            msg.sender,
            msg.value,
            block.timestamp
        );
    }
}
