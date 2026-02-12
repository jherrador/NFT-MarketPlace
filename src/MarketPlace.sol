// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract MarketPlace is ReentrancyGuard, Ownable {
    struct Listing {
        address nftAddress;
        address seller;
        uint256 tokenId;
        uint256 price;
    }
    mapping(address => mapping(uint256 => Listing)) public marketplaceListing;
    uint256 public feeListing;
    uint256 public feeSellPercentage;
    uint256 public accumulatedFees;

    event ListNft(address indexed seller_, address indexed nftAddress_, uint256 indexed tokenId_, uint256 price_);
    event CancelListNft(address indexed seller_, address indexed nftAddress_, uint256 indexed tokenId_);
    event BuyNft(
        address indexed seller_, address indexed buyer_, address indexed nftAddress_, uint256 tokenId_, uint256 price_
    );

    event FeeSellPercentage(uint256 newFee_);
    event FeeListing(uint256 newFee_);

    constructor(uint256 feeListing_, uint256 feeSellPercentage_) Ownable(msg.sender) {
        feeListing = feeListing_;
        feeSellPercentage = feeSellPercentage_;
    }

    function listNft(address nftAddress_, uint256 tokenId_, uint256 price_) external payable nonReentrant {
        require(price_ > 0, "Price can not be 0");
        address tokenOwner_ = IERC721(nftAddress_).ownerOf(tokenId_);
        require(tokenOwner_ == msg.sender, "User is not the owner of this NFT");
        require(msg.value == feeListing, "Incorrect amount of Ether");

        Listing memory listNft_ =
            Listing({nftAddress: nftAddress_, tokenId: tokenId_, price: price_, seller: msg.sender});

        marketplaceListing[nftAddress_][tokenId_] = listNft_;

        emit ListNft(msg.sender, nftAddress_, tokenId_, price_);
    }

    function cancelListNft(address nftAddress_, uint256 tokenId_) external nonReentrant {
        Listing memory listingToCancel = marketplaceListing[nftAddress_][tokenId_];
        require(listingToCancel.seller == msg.sender, "You are not the owner");

        delete (marketplaceListing[nftAddress_][tokenId_]);

        emit CancelListNft(msg.sender, nftAddress_, tokenId_);
    }

    function buyNft(address nftAddress_, uint256 tokenId_) external payable nonReentrant {
        Listing memory nftToBuy = marketplaceListing[nftAddress_][tokenId_];
        uint256 sellingFee = (nftToBuy.price * feeSellPercentage) / 100;

        require(nftToBuy.nftAddress != address(0), "NFT not listed");
        require(msg.value == nftToBuy.price, "Incorrect amount of Ether");
        require(sellingFee < nftToBuy.price, "Fee to high");

        delete (marketplaceListing[nftAddress_][tokenId_]);

        IERC721(nftAddress_).safeTransferFrom(nftToBuy.seller, msg.sender, nftToBuy.tokenId);

        uint256 priceWithFeesApplied = nftToBuy.price - sellingFee;

        (bool success,) = nftToBuy.seller.call{value: priceWithFeesApplied}("");
        require(success, "Transfer failed");

        emit BuyNft(nftToBuy.seller, msg.sender, nftToBuy.nftAddress, nftToBuy.tokenId, nftToBuy.price);
    }

    function setFeeSellPercentage(uint256 feeSellPercentage_) public onlyOwner {
        require(feeSellPercentage_ > 0, "Wrong Fee");
        feeSellPercentage = feeSellPercentage_;
        emit FeeSellPercentage(feeSellPercentage_);
    }

    function setFeeListing(uint256 feeListing_) public onlyOwner {
        require(feeListing_ > 0, "Wrong Fee");
        feeListing = feeListing_;
        emit FeeListing(feeListing_);
    }

    function withdrawFees() external onlyOwner {
        uint256 amount = address(this).balance;

        (bool success, ) = owner().call{value: amount}("");
        require(success);
    }
}
