pragma solidity ^0.4.24;

contract IAssetPurchase {

    /**
        * @dev receives the ethers to buy the license for exact asset. emit event to  proof license buying
        * @param _digitalAssetId uint256 asset id
    */
    function purchaseDigitalAsset(uint256 _digitalAssetId) public payable;
}
