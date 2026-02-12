// SPDX-License-Identifier: UNLICENSE

pragma solidity 0.8.30;

import "forge-std/Test.sol";
import {MarketPlace} from "../src/MarketPlace.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract MockNFT is ERC721 {
    constructor() ERC721("MockNFT", "MNFT") {}

    function mint(address to_, uint256 tokenId_) external {
        _mint(to_, tokenId_);
    }
}

contract MarketPlaceTest is Test {
    MarketPlace marketPlace;
    MockNFT mockNft;
    address deployer = vm.addr(1);
    address seller = vm.addr(2);
    address buyer = vm.addr(3);
    uint256 tokenId;

    function setUp() public {
        uint256 feeListing_ = 0.005 ether;
        uint256 feeSellPercentage_ = 2;
        tokenId = 0;

        vm.deal(deployer, 100 ether);
        vm.deal(seller, 100 ether);
        vm.deal(buyer, 100 ether);

        vm.startPrank(deployer);
        marketPlace = new MarketPlace(feeListing_, feeSellPercentage_);
        mockNft = new MockNFT();
        vm.stopPrank();

        _mint(seller);
    }

    function testMintNftCorrectly() public {
        _mint(seller);
    }

    function testListNftCorrectly() public {
        uint256 tokenIdMinted = _mint(seller);
        uint256 price_ = 1 ether;

        _list(price_, seller, tokenIdMinted);
        vm.stopPrank();
    }

    function testListNftRevertPriceZero() public {
        uint256 price_ = 0;
        uint256 tokenIdMinted = _mint(seller);

        vm.expectRevert("Price can not be 0");
        marketPlace.listNft(address(mockNft), tokenIdMinted, price_);
    }

    function testListNftRevertNotOwner() public {
        uint256 price_ = 1 ether;

        uint256 tokenIdMinted = _mint(seller);
        vm.startPrank(buyer);
        vm.expectRevert("User is not the owner of this NFT");
        marketPlace.listNft(address(mockNft), tokenIdMinted, price_);
        vm.stopPrank();
    }

    function testListNftRevertTokenNotExist() public {
        uint256 price_ = 1 ether;

        uint256 tokenIdMinted = _mint(seller);
        vm.startPrank(buyer);
        vm.expectRevert();
        marketPlace.listNft(address(mockNft), tokenIdMinted + 1, price_);
        vm.stopPrank();
    }

    function testListNftRevertWrongNftAddress() public {
        uint256 price_ = 1 ether;

        uint256 tokenIdMinted = _mint(seller);
        vm.startPrank(buyer);
        vm.expectRevert();
        marketPlace.listNft(address(0), tokenIdMinted + 1, price_);
        vm.stopPrank();
    }

    function testListNftRevertNoFee() public {
        uint256 price_ = 1 ether;
        uint256 tokenIdMinted = _mint(seller);

        vm.startPrank(seller);
        vm.expectRevert("Incorrect amount of Ether");
        marketPlace.listNft(address(mockNft), tokenIdMinted, price_);
        vm.stopPrank();
    }

    function testCancelListCorrectly() public {
        uint256 tokenIdMinted_ = _mint(seller);
        uint256 price_ = 1 ether;

        _list(price_, seller, tokenIdMinted_);

        (, address sellerBefore_,,) = marketPlace.marketplaceListing(address(mockNft), tokenIdMinted_);

        vm.startPrank(seller);
        marketPlace.cancelListNft(address(mockNft), tokenIdMinted_);

        (, address sellerAfter_,,) = marketPlace.marketplaceListing(address(mockNft), tokenIdMinted_);

        console.log(sellerBefore_);
        console.log(sellerAfter_);
        assert(sellerBefore_ != address(0) && sellerAfter_ != seller);
        assert(sellerAfter_ == address(0));

        vm.stopPrank();
    }

    function testCancelListRevertNotOwner() public {
        uint256 tokenIdMinted_ = _mint(seller);
        uint256 price_ = 1 ether;

        _list(price_, seller, tokenIdMinted_);

        vm.startPrank(buyer);
        vm.expectRevert("You are not the owner");
        marketPlace.cancelListNft(address(mockNft), tokenIdMinted_);

        vm.stopPrank();
    }

    function testCancelListRevertWrongTokenId() public {
        uint256 tokenIdMinted_ = _mint(seller);
        uint256 price_ = 1 ether;

        _list(price_, seller, tokenIdMinted_);

        vm.startPrank(buyer);
        vm.expectRevert("You are not the owner");
        marketPlace.cancelListNft(address(mockNft), tokenIdMinted_ + 1);

        vm.stopPrank();
    }

    function testBuyNftRevertNotListed() public {
        uint256 tokenIdMinted_ = _mint(seller);
        uint256 price_ = 1 ether;

        _list(price_, seller, tokenIdMinted_);
        vm.startPrank(buyer);
        vm.expectRevert("NFT not listed");
        marketPlace.buyNft{value: price_}(address(mockNft), tokenIdMinted_ + 1);
        vm.stopPrank();
    }

    function testBuyNftRevertWrongAmountEth() public {
        uint256 tokenIdMinted_ = _mint(seller);
        uint256 price_ = 2 ether;

        _list(price_, seller, tokenIdMinted_);

        (,,, uint256 sellingPrice_) = marketPlace.marketplaceListing(address(mockNft), tokenIdMinted_);

        vm.startPrank(buyer);
        vm.expectRevert("Incorrect amount of Ether");
        marketPlace.buyNft{value: sellingPrice_ - 1}(address(mockNft), tokenIdMinted_);
        vm.stopPrank();
    }

    function testBuyNftRevertNotApproval() public {
        uint256 tokenIdMinted_ = _mint(seller);
        uint256 price_ = 2 ether;

        _list(price_, seller, tokenIdMinted_);

        (,,, uint256 sellingPrice_) = marketPlace.marketplaceListing(address(mockNft), tokenIdMinted_);

        vm.startPrank(buyer);
        vm.expectRevert();
        marketPlace.buyNft{value: sellingPrice_}(address(mockNft), tokenIdMinted_);
        vm.stopPrank();
    }

    function testBuyNftCorrectly() public {
        uint256 tokenIdMinted_ = _mint(seller);
        uint256 price_ = 2 ether;
        uint256 sellingFee = marketPlace.feeSellPercentage();
        uint256 listingFee = marketPlace.feeListing();

        _list(price_, seller, tokenIdMinted_);

        vm.startPrank(seller);
        mockNft.approve(address(marketPlace), tokenIdMinted_);
        (,,, uint256 sellingPrice_) = marketPlace.marketplaceListing(address(mockNft), tokenIdMinted_);
        vm.stopPrank();

        uint256 sellingFeeAmount = (sellingPrice_ * sellingFee) / 100;

        vm.startPrank(buyer);
        marketPlace.buyNft{value: sellingPrice_}(address(mockNft), tokenIdMinted_);

        (, address sellerAfter,,) = marketPlace.marketplaceListing(address(mockNft), tokenIdMinted_);

        assert(buyer == mockNft.ownerOf(tokenIdMinted_));
        assert(sellerAfter == address(0));
        assert(seller != mockNft.ownerOf(tokenIdMinted_));
        assert(address(marketPlace).balance == sellingFeeAmount + listingFee);

        vm.stopPrank();
    }

    function testSetFeeSellPercentageCorrectly() public {
        uint256 marketPlaceSellingFee_ = marketPlace.feeSellPercentage();
        uint256 newFeeSellPercentage_ = 10;

        vm.startPrank(deployer);
        marketPlace.setFeeSellPercentage(newFeeSellPercentage_);

        assert(newFeeSellPercentage_ != marketPlaceSellingFee_);
        assert(marketPlace.feeSellPercentage() == newFeeSellPercentage_);
        vm.stopPrank();
    }

    function testSetFeeSellPercentageRevertNotOwner() public {
        uint256 newFeeSellPercentage_ = 10;

        vm.startPrank(buyer);
        vm.expectRevert();
        marketPlace.setFeeSellPercentage(newFeeSellPercentage_);
        vm.stopPrank();
    }

    function testSetFeeSellPercentageRevertWrongFee() public {
        uint256 newFeeSellPercentage_ = 0;

        vm.startPrank(deployer);
        vm.expectRevert("Wrong Fee");
        marketPlace.setFeeSellPercentage(newFeeSellPercentage_);
        vm.stopPrank();
    }

    function testSetFeeListingCorrectly() public {
        uint256 marketPlaceListingFee_ = marketPlace.feeListing();
        uint256 newFeeListing = 10;

        vm.startPrank(deployer);

        marketPlace.setFeeListing(newFeeListing);

        assert(newFeeListing != marketPlaceListingFee_);
        assert(marketPlace.feeListing() == newFeeListing);
        vm.stopPrank();
    }

    function testSetFeeListingRevertNotOwner() public {
        uint256 newFeeListing = 10;

        vm.startPrank(seller);
        vm.expectRevert();
        marketPlace.setFeeListing(newFeeListing);

        vm.stopPrank();
    }

    function testSetFeeListingRevertWrongFee() public {
        uint256 newFeeListing = 0;

        vm.startPrank(deployer);
        vm.expectRevert("Wrong Fee");
        marketPlace.setFeeListing(newFeeListing);

        vm.stopPrank();
    }

    function testWithdrawFees() public {
        uint256 tokenIdMinted_ = _mint(seller);
        uint256 price_ = 2 ether;

        _list(price_, seller, tokenIdMinted_);

        vm.startPrank(seller);
        mockNft.approve(address(marketPlace), tokenIdMinted_);
        (,,, uint256 sellingPrice_) = marketPlace.marketplaceListing(address(mockNft), tokenIdMinted_);
        vm.stopPrank();

        vm.startPrank(buyer);
        marketPlace.buyNft{value: sellingPrice_}(address(mockNft), tokenIdMinted_);

        vm.stopPrank();

        uint256 marketPlaceBalanceAfterSell = address(marketPlace).balance;
        uint256 deployerBalanceBeforeWithDraw = deployer.balance;

        vm.startPrank(deployer);
        marketPlace.withdrawFees();
        uint256 marketPlaceBalanceAfterWithdrawFees = address(marketPlace).balance;
        uint256 deployerBalanceAfterWithDraw = deployer.balance;
        vm.stopPrank();

        assert(deployerBalanceAfterWithDraw == deployerBalanceBeforeWithDraw + marketPlaceBalanceAfterSell);
        assert(marketPlaceBalanceAfterSell != 0);
        assert(marketPlaceBalanceAfterWithdrawFees == 0);
    }

    function testWithdrawFeesRevertNotOwner() public {
        uint256 tokenIdMinted_ = _mint(seller);
        uint256 price_ = 2 ether;

        _list(price_, seller, tokenIdMinted_);

        vm.startPrank(seller);
        mockNft.approve(address(marketPlace), tokenIdMinted_);
        (,,, uint256 sellingPrice_) = marketPlace.marketplaceListing(address(mockNft), tokenIdMinted_);
        vm.stopPrank();

        vm.startPrank(buyer);
        marketPlace.buyNft{value: sellingPrice_}(address(mockNft), tokenIdMinted_);

        vm.stopPrank();

        vm.startPrank(buyer);
        vm.expectRevert();
        marketPlace.withdrawFees();
        vm.stopPrank();
    }

    // Helper

    function _list(uint256 price_, address owner_, uint256 tokenIdMinted_) private {
        uint256 listingFee = marketPlace.feeListing();
        (, address ownerBefore_,,) = marketPlace.marketplaceListing(address(mockNft), tokenIdMinted_);
        uint256 sellerBalanceBefore_ = owner_.balance;
        uint256 marketPlaceListingFee = marketPlace.feeListing();
        uint256 marketPlaceInitialBalance = address(marketPlace).balance;

        vm.startPrank(owner_);
        marketPlace.listNft{value: listingFee}(address(mockNft), tokenIdMinted_, price_);

        (address listerNft_, address ownerAfter_, uint256 listedNftTokenId_, uint256 priceAfter_) =
            marketPlace.marketplaceListing(address(mockNft), tokenIdMinted_);

        assert(ownerBefore_ == address(0) && ownerBefore_ != ownerAfter_);
        assert(ownerAfter_ == owner_);
        assert(listerNft_ == address(mockNft));
        assert(priceAfter_ == price_);
        assert(listedNftTokenId_ == tokenIdMinted_);

        assert(owner_.balance == sellerBalanceBefore_ - marketPlaceListingFee);
        assert(address(marketPlace).balance == marketPlaceInitialBalance + marketPlaceListingFee);

        vm.stopPrank();
    }

    function _mint(address owner_) private returns (uint256) {
        vm.startPrank(owner_);
        mockNft.mint(owner_, tokenId);
        vm.stopPrank();

        address nftOwner = mockNft.ownerOf(tokenId);
        assert(nftOwner == seller);

        tokenId++;

        return tokenId - 1;
    }
}
