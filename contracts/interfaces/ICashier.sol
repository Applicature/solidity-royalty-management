pragma solidity 0.4.24;


contract ICashier {

    /**
        * @dev receives and transfer ethers to asset owner and platform related address
            from AssetPurchase contract paid to by license
        * @param _digitalAssetId uint256 asset id
    */
    function recordPurchase(uint256 _digitalAssetId) public payable;

    /**
        * @dev receives and transfer ethers from Royalty contract paid to register new asset
    */
    function forwardEthersToHolder() public payable;
}
