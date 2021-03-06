// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract WhaleNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Token name and symbol
    constructor() public ERC721("WhaleNFT", "WNFT") {}

    /**
     * mintNFT and transfer to recipient
     */
    function mintNFT(address recipient, string memory tokenURI)
        public
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }

    /**
     * minNFT and transfer to sender(myself)
     */
    function mintNFTMyself(string memory tokenURI)
        public
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }
}


/**
 * ERC721 based transfer contract
 * provides functions to register and purchase items for sale
 */
contract TransferWhaleNFT {
    address private _contractOwner;

    // Owner who deployed this contract
    constructor () payable {
        _contractOwner = msg.sender;
    }

    /**
     * room statuses
     * 0: not created
     * 1: item posted for sale
     * 2: transfer ended
     * 3: error    
     */
    enum TradeStatus {  
        STATUS_NOT_CREATED, STATUS_POST, STATUS_COMPLETE, STATUS_ERROR 
    }

    // NFT's contranct address and token id
    struct NFTProduct {
        address contractAddr;
        uint256 tokenId;
    }

    // Room for sell NFT
    struct TradeRoom {
        NFTProduct nftProduct;
        uint256 price;
        address payable sellerAddr;
        TradeStatus tradeStatus;
    }

    // Mapping from room list to trade room
    mapping(uint => TradeRoom) rooms;
    uint roomLen = 0;

    // Emits when room has created
    event SellPosted (address indexed sellerAddress, uint256 price, uint256 roomNumber);

    // Emits when transfer has ended successfully
    event TransferSuccess (address indexed seller, address indexed buyer, uint256 price, uint256 roomNumber);

    /**
     * Posts ERC721 based NFT item sender wants to sell
     * warn: before use 'sell' transfer, NFT needs to be approved to this contract
     * this transaction could execute by owner of NFT or owner of this contract.
     * check if NFT got approved. if not transaction would fail
     * returns number of room made and emits event to see information
     */
    function sell(address _nftContract, uint256 _tokenId, uint256 _price) public returns (uint roomNum) {
        require (msg.sender == ERC721(_nftContract).ownerOf(_tokenId) || msg.sender == _contractOwner,  "TransferWhaleNFT: token owner or contract owner can sell item");
        require (ERC721(_nftContract).getApproved(_tokenId) == address(this), "TransferWhaleNFT: token is not approved");

        rooms[roomLen] = TradeRoom({
            nftProduct: NFTProduct({
                contractAddr: _nftContract,
                tokenId: _tokenId
            }),
            price: _price,
            sellerAddr: payable(msg.sender),
            tradeStatus: TradeStatus.STATUS_POST
        });
        roomNum = roomLen;
        roomLen = roomLen + 1;

        emit SellPosted(msg.sender, _price, roomNum);
    }

    /**
     * Buy posted nft item with room number
     * needs exact value which is price of posted NFT (can find out by function roomInfo)
     * transfer buyer's eth to seller and nft transfers to buyer
     */
    function buy(uint256 _roomNumber)
        public
        payable
    {
        uint256 price = rooms[_roomNumber].price;
        uint256 tokenId = rooms[_roomNumber].nftProduct.tokenId;
        require(
            msg.value == price,
            "TransferWhaleNFT: Please submit the asking price in order to complete the purchase"
        );

        rooms[_roomNumber].sellerAddr.transfer(msg.value);
        ERC721(rooms[_roomNumber].nftProduct.contractAddr).transferFrom(rooms[_roomNumber].sellerAddr, msg.sender, tokenId);
        rooms[_roomNumber].tradeStatus = TradeStatus.STATUS_COMPLETE;
        emit TransferSuccess (rooms[_roomNumber].sellerAddr, msg.sender, price, _roomNumber);
    }

    /**
     * Get room information by room number
     * check if room is valid and returns room status, nft contract address, nft token id and price
     */
    function roomInfo(uint256 _roomNumber) public view returns (TradeStatus, address, uint256, uint256) {
        require(_roomNumber < roomLen, "TransferWhaleNFT: Invalid room number");
        return(rooms[_roomNumber].tradeStatus, rooms[_roomNumber].nftProduct.contractAddr, rooms[_roomNumber].nftProduct.tokenId, rooms[_roomNumber].price);
    }

    /**
     * Get total room count
     */
    function roomCount() public view returns (uint count) {
        count = roomLen;
    }
}