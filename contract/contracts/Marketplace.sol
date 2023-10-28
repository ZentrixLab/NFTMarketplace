// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Marketplace is ReentrancyGuard {
    
    address payable owner; 
    uint256 public feePercent;
    uint256 public itemCount;

    struct Item {
        uint itemId;
        IERC721 nft;
        uint256 tokenId;
        uint256 price;
        address payable seller;
        bool sold;
    }

    mapping(uint256 => Item) public items;

    constructor(uint256 _feePercent) {
        owner = payable(msg.sender);
        feePercent = _feePercent;
    }

    event Offered(
        uint itemId,
        address indexed nft,
        uint256 tokenId,
        uint256 price,
        address indexed seller
    );

    event Bought(
        uint itemId,
        address indexed nft,
        uint256 tokenId,
        uint256 price,
        address indexed seller,
        address indexed buyer
    );

    function addItem(
        IERC721 _nft,
        uint256 _tokenId,
        uint256 _price
    ) external nonReentrant {
        require(_price > 0, "Error: Price must be greater than zero");
        require(IERC721(_nft).ownerOf(_tokenId) == msg.sender, "Error: msg.sender doesn't own nft")

        // nft transfer should be approved 
        // _nft.transferFrom(msg.sender, address(this), _tokenId);
        require(_nft.getApproved(_tokenId) == address(this), "Error: token transfer not approved");
        
        items[itemCount] = Item(
            itemCount,
            _nft,
            _tokenId,
            _price,
            payable(msg.sender),
            false
        );
        emit Offered(itemCount, address(_nft), _tokenId, _price, msg.sender);
        itemCount++;
    }

    function buyItem(uint256 _itemId) external payable nonReentrant {
        require(_itemId > 0 && _itemId <= itemCount, "Error: item doesn't exist");
        uint256 _totalPrice = getTotalPrice(_itemId);
        Item storage item = items[_itemId];
        require(msg.value >= _totalPrice, "Error: not enough ether provided");
        require(!item.sold, "Error: item already sold");

        _transferMatic(item.seller, item.price);
        _transferMatic(owner, _totalPrice - item.price);

        item.nft.transferFrom(address(this), msg.sender, item.tokenId);
        item.sold = true;

        emit Bought(
            _itemId,
            address(item.nft),
            item.tokenId,
            item.price,
            item.seller,
            msg.sender
        );
    }

    function getTotalPrice(uint256 _itemId) public view returns (uint256256) {
        return ((items[_itemId].price * (100 + feePercent)) / 100);
    }

    function _transferMatic(address payable _to, uint256 _amount) internal {
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Error: Transaction failed");
    }
}
