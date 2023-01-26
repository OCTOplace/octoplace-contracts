// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool _approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

interface ISwapData {
    struct SwapListing {
        uint256 listingId;
        IERC721 tokenAddress;
        uint256 tokenId;
        address tokenOwner;
        uint256 transactionChargeBips;
        bool isCompleted;
        bool isCancelled;
        uint256 transactionCharge;
    }

    struct SwapOffer {
        uint256 offerId;
        uint256 listingId;
        IERC721 offerTokenAddress;
        uint256 offerTokenId;
        address offerTokenOwner;
        IERC721 listingTokenAddress;
        uint256 listingTokenId;
        address listingTokenOwner;
        uint256 transactionChargeBips;
        bool isCompleted;
        bool isCancelled;
        bool isDeclined;
        uint256 transactionCharge;
    }

    struct Trade {
        uint256 tradeId;
        uint256 listingId;
        uint256 offerId;
    }

    event SwapListingAdded(SwapListing listing);
    event SwapListingUpdated(SwapListing listing);
    event SwapListingRemoved(uint256 listingId);
    event SwapOfferAdded(SwapOffer offer);
    event SwapOfferUpdated(SwapOffer offer);
    event SwapOfferRemoved(uint256 id);
    event TradeAdded(Trade trade);

    function addListing(SwapListing memory listing) external returns (bool);

    function removeListingById(uint256 id) external;

    function updateListing(SwapListing memory listing) external;

    function readListingById(uint256 id)
        external
        view
        returns (SwapListing memory);

    function addOffer(SwapOffer memory offer) external returns (bool);

    function removeOfferById(uint256 id) external;

    function updateOffer(SwapOffer memory offer) external;

    function readOfferById(uint256 id) external view returns (SwapOffer memory);

    function addTrade(Trade memory trade) external;

    function readTradeById(uint256 id) external view returns (Trade memory);

    function readAllListings() external view returns (SwapListing[] memory);

    function readAllOffers() external view returns (SwapOffer[] memory);

    function readAllTrades() external view returns (Trade[] memory);
}


interface IAccessControl {
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

abstract contract ERC165 is IERC165 {

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

contract SwapNFT is Context, AccessControl {
    ISwapData private dataContract;

    uint256 private totalBips = 10000;
    uint256 public txCharge = 10 * 10 ** 18;

    event SwapListingCreated(
        address collectionAddress,
        address createdBy,
        uint256 tokenId
    );
    event SwapOfferCreated(
        uint256 listingId,
        address from,
        address offerCollection,
        uint256 tokenId
    );

    event SwapOfferDeclied(
        address declinedBy,
        uint256 offerId,
        uint256 listingId
    );
    event SwapOfferAccepted(
        address acceptedBy,
        uint256 offerId,
        uint256 listingId
    );
    event SwapOfferWithdraw(address owner, uint256 offerId);
    event SwapListingWithdraw(address owner, uint256 listingId);
    event TxChargeChanged(uint256 newTxCharge);
    event TreasuryWalletChanged(address newTreasuryWallet);

    address treasury;

    constructor(address admin_, address dataContract_) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin_);
        dataContract = ISwapData(dataContract_);
        treasury = _msgSender();
    }

    function createListing(
        uint256 tokenId_,
        address nftContract_
    ) external payable {
        IERC721 nftContract = IERC721(nftContract_);
        bool isApproved = nftContract.isApprovedForAll(
            _msgSender(),
            address(this)
        );
        require(msg.value >= txCharge, "Insufficient tfuel sent for txCharge");
        require(
            isApproved,
            "Approval is required for Swap Contract before listing."
        );
        require(
            nftContract.ownerOf(tokenId_) == _msgSender(),
            "You are not the owner of the NFT"
        );
        ISwapData.SwapListing memory listing;
        listing.listingId = 0;
        listing.tokenAddress = nftContract;
        listing.tokenId = tokenId_;
        listing.tokenOwner = _msgSender();
        listing.transactionChargeBips = 5000;
        listing.isCompleted = false;
        listing.isCancelled = false;
        listing.transactionCharge = txCharge;
        bool isListingCreated = dataContract.addListing(listing);
        require(isListingCreated, "Listing cannot be created");
        emit SwapListingCreated(address(nftContract), _msgSender(), tokenId_);
    }

    function createOffer(
        uint256 tokenId_,
        address nftContract_,
        uint256 listingId_
    ) external {
        IERC721 nftContract = IERC721(nftContract_);
        bool isApproved = nftContract.isApprovedForAll(
            _msgSender(),
            address(this)
        );
        require(
            isApproved,
            "Approval is required for Swap Contract before listing."
        );
        require(
            nftContract.ownerOf(tokenId_) == _msgSender(),
            "You are not the owner of the NFT"
        );
        ISwapData.SwapListing memory listing = dataContract.readListingById(
            listingId_
        );
        IERC721 listingNftContract = IERC721(listing.tokenAddress);
        require(
            listingNftContract.ownerOf(listing.tokenId) == listing.tokenOwner,
            "Listing Expired"
        );
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
        emit SwapOfferCreated(
            listingId_,
            _msgSender(),
            address(nftContract),
            tokenId_
        );
    }

    function declineOffer(uint256 offerId_, uint256 listingId_) external {
        ISwapData.SwapOffer memory offer = dataContract.readOfferById(offerId_);
        ISwapData.SwapListing memory listing = dataContract.readListingById(
            listingId_
        );
        require(
            offer.listingTokenId == listing.tokenId,
            "Inecorrect attempt to decline offer."
        );
        require(
            offer.listingTokenOwner == _msgSender(),
            "You are not authorized to decline offers for this listing."
        );
        offer.isDeclined = true;
        dataContract.updateOffer(offer);
        emit SwapOfferDeclied(_msgSender(), offerId_, listingId_);
    }

    function acceptOffer(uint256 offerId_, uint256 listingId_) external {
        ISwapData.SwapOffer memory offer = dataContract.readOfferById(offerId_);
        ISwapData.SwapListing memory listing = dataContract.readListingById(
            listingId_
        );
        IERC721 offerContract = IERC721(offer.offerTokenAddress);
        IERC721 listingContract = IERC721(offer.listingTokenAddress);
        require(offer.listingTokenId == listing.tokenId, "Incorrect listing");
        IERC721 listingNftContract = IERC721(listing.tokenAddress);
        require(
            listingNftContract.ownerOf(listing.tokenId) == _msgSender(),
            "You are not the owner of this listing"
        );
        require(
            offer.listingTokenId == listing.tokenId,
            "Inecorrect attempt to accept offer."
        );
        require(!listing.isCompleted && !offer.isCompleted, "Invalid request.");
        require(!listing.isCancelled && !offer.isCancelled, "Invalid Request.");
        require(!offer.isDeclined, "Invalid Request");
        offerContract.transferFrom(
            offer.offerTokenOwner,
            offer.listingTokenOwner,
            offer.offerTokenId
        );
        listingContract.transferFrom(
            offer.listingTokenOwner,
            offer.offerTokenOwner,
            offer.listingTokenId
        );
        _safeTransferNative(treasury, listing.transactionCharge);
        listing.isCompleted = true;
        offer.isCompleted = true;
        dataContract.updateListing(listing);
        dataContract.updateOffer(offer);
        ISwapData.Trade memory trade;
        trade.listingId = listing.listingId;
        trade.offerId = offer.offerId;
        dataContract.addTrade(trade);
        emit SwapOfferAccepted(_msgSender(), offerId_, listingId_);
    }

    function readAllListings()
        external
        view
        returns (ISwapData.SwapListing[] memory)
    {
        return dataContract.readAllListings();
    }

    function readListingById(
        uint256 id
    ) external view returns (ISwapData.SwapListing memory) {
        return dataContract.readListingById(id);
    }

    function removeListingById(uint256 id) external {
        ISwapData.SwapListing memory listing = dataContract.readListingById(id);
        require(
            _msgSender() == listing.tokenOwner,
            "Only listing creators can remove listings."
        );
        _safeTransferNative(_msgSender(), listing.transactionCharge);
        dataContract.removeListingById(id);
        emit SwapListingWithdraw(_msgSender(), id);
    }

    function readAllOffers()
        external
        view
        returns (ISwapData.SwapOffer[] memory)
    {
        return dataContract.readAllOffers();
    }

    function readOfferById(
        uint256 id
    ) external view returns (ISwapData.SwapOffer memory) {
        return dataContract.readOfferById(id);
    }

    function removeOfferById(uint256 id) external {
        ISwapData.SwapOffer memory offer = dataContract.readOfferById(id);
        require(
            _msgSender() == offer.offerTokenOwner,
            "Only offer creators can remove offers."
        );
        dataContract.removeOfferById(id);
        emit SwapOfferWithdraw(_msgSender(), id);
    }

    function readAllTrades() external view returns (ISwapData.Trade[] memory) {
        return dataContract.readAllTrades();
    }

    function readTradeById(
        uint256 id
    ) external view returns (ISwapData.Trade memory) {
        return dataContract.readTradeById(id);
    }

    function setTxCharge(
        uint256 newTxCharge
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        txCharge = newTxCharge;
        emit TxChargeChanged(newTxCharge);
    }

    function setTreasuryWallet(
        address newTreasury
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        treasury = newTreasury;
        emit TreasuryWalletChanged(newTreasury);
    }

    function getTxCharge() external view returns (uint256) {
        return txCharge;
    }

    function _safeTransferNative(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}("");
        require(success, "TransferHelper: TRANSFER_FAILED");
    }
}
