//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./interfaces/ISwapData.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract SwapNFT is Context,  AccessControl {

    IERC20 private _feeToken;
    ISwapData private dataContract;

    uint256 private totalBips = 10000;
    uint256 public txCharge = 10 * 10**18;

    address treasury;
    constructor(address admin_,  address dataContract_) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin_);
        dataContract = ISwapData(dataContract_);
        treasury = _msgSender();
    }

    function createListing(uint256 tokenId_, address nftContract_) external payable {
        IERC721 nftContract = IERC721(nftContract_);
        bool isApproved = nftContract.isApprovedForAll(_msgSender(), address(this));
        require(msg.value >= txCharge, "Insufficient tfuel sent for txCharge");
        require(isApproved, "Approval is required for Swap Contract before listing.");
        require(nftContract.ownerOf(tokenId_) == _msgSender(), "You are not the owner of the NFT");
        ISwapData.SwapListing memory listing;
        listing.listingId = 0;
        listing.tokenAddress = nftContract;
        listing.tokenId = tokenId_;
        listing.tokenOwner = _msgSender();
        listing.transactionChargeBips= 5000;
        listing.isCompleted = false;
        listing.isCancelled = false;
        listing.transactionCharge = txCharge;
        bool isListingCreated = dataContract.addListing(listing);
        require(isListingCreated, "Listing cannot be created");
    }

    function createOffer(uint256 tokenId_, address nftContract_, uint256 listingId_) external{
        IERC721 nftContract = IERC721(nftContract_);
        bool isApproved = nftContract.isApprovedForAll(_msgSender(), address(this));
        require(isApproved, "Approval is required for Swap Contract before listing.");
        require(nftContract.ownerOf(tokenId_) == _msgSender(), "You are not the owner of the NFT");
        ISwapData.SwapListing memory listing = dataContract.readListingById(listingId_);
        IERC721 listingNftContract = IERC721(listing.tokenAddress);
        require(listingNftContract.ownerOf(listing.tokenId) == listing.tokenOwner, "Listing Expired");
        ISwapData.SwapOffer memory offer;
        offer.offerTokenAddress = nftContract;
        offer.listingId = listingId_;
        offer.offerTokenId = tokenId_;
        offer.offerTokenOwner = _msgSender();
        offer.listingTokenAddress = listing.tokenAddress;
        offer.listingTokenId = listing.tokenId;
        offer.listingTokenOwner = listing.tokenOwner;
        offer.transactionChargeBips = 5000;
        offer.isCompleted = false;
        offer.isCancelled = false;
        offer.isDeclined = false;
        offer.transactionCharge = txCharge;
        bool isofferCreated = dataContract.addOffer(offer);
        require(isofferCreated, "Offer canot be created.");
    }

    function declineOffer(uint256 offerId_, uint256 listingId_) external {
        ISwapData.SwapOffer memory offer = dataContract.readOfferById(offerId_);
        ISwapData.SwapListing memory listing = dataContract.readListingById(listingId_);
        require(offer.listingTokenId == listing.tokenId, "Inecorrect attempt to decline offer.");
        require(offer.listingTokenOwner == _msgSender(), "You are not authorized to decline offers for this listing.");
        offer.isDeclined = true;
        dataContract.updateOffer(offer);
    }

    function acceptOffer(uint256 offerId_, uint256 listingId_) external {
        ISwapData.SwapOffer memory offer = dataContract.readOfferById(offerId_);
        ISwapData.SwapListing memory listing = dataContract.readListingById(listingId_);
        IERC721 offerContract = IERC721(offer.offerTokenAddress);
        IERC721 listingContract = IERC721(offer.listingTokenAddress);
        require(offer.listingTokenId == listing.tokenId, "Incorrect listing");
        IERC721 listingNftContract = IERC721(listing.tokenAddress);
        require(listingNftContract.ownerOf(listing.tokenId) == _msgSender(), "You are not the owner of this listing");
        require(offer.listingTokenId == listing.tokenId, "Inecorrect attempt to accept offer.");
        require(!listing.isCompleted && !offer.isCompleted, "Invalid request.");
        require(!listing.isCancelled && !offer.isCancelled, "Invalid Request." );
        require(!offer.isDeclined, "Invalid Request");
        offerContract.transferFrom(offer.offerTokenOwner, offer.listingTokenOwner, offer.offerTokenId);
        listingContract.transferFrom(offer.listingTokenOwner, offer.offerTokenOwner, offer.listingTokenId);
        _safeTransferNative(treasury, listing.transactionCharge);
        listing.isCompleted = true;
        offer.isCompleted = true;
        dataContract.updateListing(listing);
        dataContract.updateOffer(offer);
        ISwapData.Trade memory trade;
        trade.listingId = listing.listingId;
        trade.offerId = offer.offerId;
        dataContract.addTrade(trade);
    }

    function readAllListings() external view returns (ISwapData.SwapListing[] memory){
        return dataContract.readAllListings();
    }

    function readListingById(uint256 id) external view returns (ISwapData.SwapListing memory){
        return dataContract.readListingById(id);
    }

    function removeListingById(uint256 id) external {
        ISwapData.SwapListing memory listing = dataContract.readListingById(id);
        require(_msgSender() == listing.tokenOwner, "Only listing creators can remove listings.");
        _safeTransferNative(_msgSender(), listing.transactionCharge);
        return dataContract.removeListingById(id);
    }

    function readAllOffers() external view returns(ISwapData.SwapOffer[] memory){
        return dataContract.readAllOffers();
    }

    function readOfferById(uint256 id) external view returns (ISwapData.SwapOffer memory){
        return dataContract.readOfferById(id);
    }

    function removeOfferById(uint256 id) external {
        return dataContract.removeOfferById(id);
    }

    function readAllTrades() external view returns(ISwapData.Trade[] memory){
        return dataContract.readAllTrades();
    }

    function readTradeById(uint256 id) external view returns(ISwapData.Trade memory){
        return dataContract.readTradeById(id);
    }

    function setTxCharge(uint256 newTxCharge)  onlyRole(DEFAULT_ADMIN_ROLE) external {
        txCharge = newTxCharge;
    }

    function setTreasuryWallet(address newTreasury) onlyRole(DEFAULT_ADMIN_ROLE) external {
        treasury = newTreasury;
    }

    function getTxCharge() external view returns(uint256) {
        return txCharge;
    }
    
    function _safeTransferNative(
        address to, 
        uint256 value
        ) 
        internal
    {
        (bool success, ) = to.call{value: value}("");
        require(success, "TransferHelper: TRANSFER_FAILED");
    }
}
