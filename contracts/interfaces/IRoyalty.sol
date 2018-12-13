pragma solidity ^0.4.24;

contract IRoyalty {

    /**
       * @dev to create and pay fee for digitalAssets
       * @param _price uint256 license price in Ethers
       * @param _uri string URI to assign
       * @param _dataGenerationTimestamp uint256 timestamp  where transaction data was signed
   */
    function createDigitalAssets(
        uint256 _price,
        string _uri,
        uint256 _dataGenerationTimestamp,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
    public
    payable;

    /**
      * @dev to get the license price
      * @param _digitalAssetId uint256 id of exact Asset
      * @return uint256 price in ethers
    */
    function getEtherPriceForAsset(uint256 _digitalAssetId)
        public
        view
        returns(uint256);

    /**
    * @dev check the signer of the tansaction
    * @param _owner address Address of creator of the assets
    * @param _amount signed for this transaction
    * @param _uri string URI to assign
    * @param _dataGenerationTimestamp uint256 timestamp where transaction data was signed
    * @return address sign the transaction
    */
    function verify(
        address _owner,
        uint256 _amount,
        string _uri,
        uint256 _dataGenerationTimestamp,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        public
        pure
        returns (address);


    /**
       * @dev to create and pay fee for digitalAssets
       * @param _tokenOwner address Address of creator of the assets
       * @param _priceInEthers uint256 license price in Ethers
       * @param _uri string URI to assign
    */
    function createDigitalAssetInternal(
        address _tokenOwner,
        uint256 _priceInEthers,
        string _uri
    )
        internal
        returns (uint256 digitalAssetId);

}
