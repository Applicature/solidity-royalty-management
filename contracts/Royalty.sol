pragma solidity 0.4.24;

import 'openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol';
import './Managed.sol';


contract Royalty is ERC721Token, Managed {

    DigitalAsset[] public digitalAssets;

    struct DigitalAsset {
        uint256 priceInEthers;

    }

    constructor(address _management)
        public
        ERC721Token('Royalty', 'ROYALTY')
        Managed(_management)
    {}

    function createDigitalAssets(
        uint256 _priceInEthers,
        string _uri
    )
        public
    {
        createDigitalAssetInternal(
            msg.sender,
            _priceInEthers,
            _uri
        );
    }

    function approve(address _to, uint256 _tokenId) public {
        _to = _to;
        _tokenId = _tokenId;
        require(false, ERROR_ACCESS_DENIED);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        public
    {
        _from = _from;
        _to = _to;
        _tokenId = _tokenId;
        require(false, ERROR_ACCESS_DENIED);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        public
    {
        _from = _from;
        _to = _to;
        _tokenId = _tokenId;
        require(false, ERROR_ACCESS_DENIED);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    ) public {
        _from = _from;
        _to = _to;
        _tokenId = _tokenId;
        _data = _data;
        require(false, ERROR_ACCESS_DENIED);
    }

    function getEtherPriceForAsset(uint256 _digitalAssetId)
        public
        returns(uint256)
    {
        return digitalAssets[_digitalAssetId].priceInEthers;
    }
    
    function createDigitalAssetInternal(
        address _tokenOwner,
        uint256 _priceInEthers,
        string _uri
    )
        internal
    {
        require(
            _tokenOwner != address(0) &&
            false == isContract(_tokenOwner),
            ERROR_ACCESS_DENIED
        );
        uint256 digitalAssetId = allTokens.length;
        _mint(_tokenOwner, digitalAssetId);
        _setTokenURI(digitalAssetId, _uri);
        digitalAssets.push(DigitalAsset(_priceInEthers));
    }
}