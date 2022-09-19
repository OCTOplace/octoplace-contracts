//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract SwapData is AccessControl {

    using Counters for Counters.Counter;

struct SwapListing {
        uint256 listingId;
        IERC721 TokenAddress;
        uint256 tokenId;
        address tokenOwner;
        uint256 transactionChargeBips;
        bool isCompleted;
        bool isCancelled;
        uint256 transactionCharge;
    }

    struct SwapOffer {
        uint256 offerId;
        IERC721 offerTokenAddress;
        uint256 offerTokenId;
        address offerTokenOwner;
        IERC721 listingTokenAddress;
        uint256 listingTokenId;
        address listingTokenOwner;
        uint256 transactionChargeBips;
        bool isCompleted;
        bool isCancelled;
        uint256 transactionCharge;
    }

    struct Trade {
        uint256 tradeId;
        uint256 listingId;
        uint256 offerId;
    }


    bytes32 public constant DATA_READER = keccak256("READ_DATA");
    bytes32 public constant DATA_WRITER = keccak256("WRITE_DATA");
    bytes32 public constant DATA_MIGRATOR = keccak256("DATA_MIGRATOR");

    Counters.Counter private _listingIdTracker;
    Counters.Counter private _offerIdTracker;
    Counters.Counter private _tradeIdTracker;

    mapping(uint256 => SwapListing) private _listings;
    mapping(uint256 => SwapOffer) private _offers;
    mapping(uint256 => Trade) private _trades;

    constructor(address admin, address reader, address writer){
        _grantRole(DEFAULT_ADMIN_ROLE, admin); // Admin Wallet address
        _grantRole(DATA_READER, reader); // Swap contract
        _grantRole(DATA_WRITER, writer); // Swap COntract
        _listingIdTracker.increment();
        _offerIdTracker.increment();
        _tradeIdTracker.increment();
    }

    // CRUD Listing
    function addListing(SwapListing memory listing) external onlyRole(DATA_WRITER) {
        listing.listingId = _listingIdTracker.current();
        _listings[_listingIdTracker.current()] = listing;
        _listingIdTracker.increment();
    }

    function removeListingById(uint256 id) external onlyRole(DATA_WRITER) {
        _listings[id].isCancelled = true;
    }

    function updateListing(SwapListing memory listing) external onlyRole(DATA_WRITER){
        _listings[listing.listingId] = listing;
    }

    function readListingById(uint256 id)external view onlyRole(DATA_READER) returns(SwapListing memory) {
        return _listings[id];
    }
 

    // CRUD Offer
    function addOffer(SwapOffer memory offer) external onlyRole(DATA_WRITER) {
        offer.offerId = _offerIdTracker.current();
        _offers[_offerIdTracker.current()] = offer;
        _offerIdTracker.increment();
    }

    function removeOfferById(uint256 id) external onlyRole(DATA_WRITER) {
        _offers[id].isCancelled = true;
    }

    function updateOffer(SwapOffer memory offer) external onlyRole(DATA_WRITER){
        _offers[offer.offerId] = offer;
    }

    function readOfferById(uint256 id)external view onlyRole(DATA_READER) returns(SwapOffer memory) {
        return _offers[id];
    }

    function addTrade(Trade memory trade) external onlyRole(DATA_WRITER) {
        trade.tradeId = _tradeIdTracker.current();
        _trades[_tradeIdTracker.current()] = trade;
        _tradeIdTracker.increment();
    }

    function readTradeById(uint256 id)external view onlyRole(DATA_READER) returns (Trade memory){
        return _trades[id];
    }

    // Bulk reads
    function readAllListings()external view onlyRole(DATA_READER) returns (SwapListing[] memory){
        SwapListing[] memory listings = new SwapListing[](_listingIdTracker.current());
        for (uint256 i = 0; i < _listingIdTracker.current(); i++){
            listings[i] = _listings[i];
        }
        return listings;
    }

    function readAllOffers() external view onlyRole(DATA_READER) returns (SwapOffer[] memory){
        SwapOffer[] memory swapOffers = new SwapOffer[](_offerIdTracker.current());
        for(uint256 i = 0; i < _offerIdTracker.current(); i++){
            swapOffers[i] = _offers[i];
        }
        return swapOffers;
    }

    function readAllTrades() external view onlyRole(DATA_READER) returns (Trade[] memory){
        Trade[] memory trades = new Trade[](_tradeIdTracker.current());
        for(uint256 i = 0 ; i < _tradeIdTracker.current();i++){
            trades[i] = _trades[i];
        }
        return trades;
    }
 

    IERC20 public transactionToken;

    
}
