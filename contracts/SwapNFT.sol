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

    constructor(address admin_,  address dataContract_) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin_);
        dataContract = ISwapData(dataContract_);
    }

    function createListing(uint256 tokenId_, address nftContract_) external {
        IERC721 nftContract = IERC721(nftContract_);
        bool isApproved = nftContract.isApprovedForAll(_msgSender(), address(this));
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
}
