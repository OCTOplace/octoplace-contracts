// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

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

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
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

library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

contract SwapData is AccessControl {
    using Counters for Counters.Counter;

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

    bytes32 public constant DATA_WRITER = keccak256("WRITE_DATA");
    bytes32 public constant DATA_MIGRATOR = keccak256("DATA_MIGRATOR");

    Counters.Counter private _listingIdTracker;
    Counters.Counter private _offerIdTracker;
    Counters.Counter private _tradeIdTracker;

    mapping(uint256 => SwapListing) private _listings;
    mapping(uint256 => SwapOffer) private _offers;
    mapping(uint256 => Trade) private _trades;

    event SwapListingAdded(SwapListing listing);
    event SwapListingUpdated(SwapListing listing);
    event SwapListingRemoved(uint256 listingId);
    event SwapOfferAdded(SwapOffer offer);
    event SwapOfferUpdated(SwapOffer offer);
    event SwapOfferRemoved(uint256 id);
    event TradeAdded(Trade trade);

    constructor(
        address admin,
        address writer
    ) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin); // Admin Wallet address
        _grantRole(DATA_WRITER, writer); // Swap COntract
        _listingIdTracker.increment();
        _offerIdTracker.increment();
        _tradeIdTracker.increment();
    }

    // CRUD Listing
    function addListing(SwapListing memory listing)
        external
        onlyRole(DATA_WRITER)
        returns (bool)
    {
        listing.listingId = _listingIdTracker.current();
        _listings[_listingIdTracker.current()] = listing;
        _listingIdTracker.increment();
        emit SwapListingAdded(listing);
        return true;
    }

    function removeListingById(uint256 id)
        external
        onlyRole(DATA_WRITER)
        returns (bool)
    {
        _listings[id].isCancelled = true;
        emit SwapListingRemoved(id);
        return true;
    }

    function updateListing(SwapListing memory listing)
        external
        onlyRole(DATA_WRITER)
        returns (bool)
    {
        _listings[listing.listingId] = listing;
        emit SwapListingUpdated(listing);
        return true;
    }

    function readListingById(uint256 id)
        external
        view
        returns (SwapListing memory)
    {
        return _listings[id];
    }

    // CRUD Offer
    function addOffer(SwapOffer memory offer)
        external
        onlyRole(DATA_WRITER)
        returns (bool)
    {
        offer.offerId = _offerIdTracker.current();
        _offers[_offerIdTracker.current()] = offer;
        _offerIdTracker.increment();
        emit SwapOfferAdded(offer);
        return true;
    }

    function removeOfferById(uint256 id)
        external
        onlyRole(DATA_WRITER)
        returns (bool)
    {
        _offers[id].isCancelled = true;
        emit SwapOfferRemoved(id);
        return true;
    }

    function updateOffer(SwapOffer memory offer)
        external
        onlyRole(DATA_WRITER)
        returns (bool)
    {
        _offers[offer.offerId] = offer;
        emit SwapOfferUpdated(offer);
        return true;
    }

    function readOfferById(uint256 id)
        external
        view
        returns (SwapOffer memory)
    {
        return _offers[id];
    }

    function addTrade(Trade memory trade)
        external
        onlyRole(DATA_WRITER)
        returns (bool)
    {
        trade.tradeId = _tradeIdTracker.current();
        _trades[_tradeIdTracker.current()] = trade;
        _tradeIdTracker.increment();
        emit TradeAdded(trade);
        return true;
    }

    function readTradeById(uint256 id)
        external
        view
        returns (Trade memory)
    {
        return _trades[id];
    }

    // Bulk reads
    function readAllListings()
        external
        view
        returns (SwapListing[] memory)
    {
        SwapListing[] memory listings = new SwapListing[](
            _listingIdTracker.current() - 1
        );
        for (uint256 i = 0; i < listings.length; i++) {
            listings[i] = _listings[i + 1];
        }
        return listings;
    }

    function readAllOffers()
        external
        view
        returns (SwapOffer[] memory)
    {
        SwapOffer[] memory swapOffers = new SwapOffer[](
            _offerIdTracker.current() - 1
        );
        for (uint256 i = 0; i < swapOffers.length; i++) {
            swapOffers[i] = _offers[i + 1];
        }
        return swapOffers;
    }

    function readAllTrades()
        external
        view
        returns (Trade[] memory)
    {
        Trade[] memory trades = new Trade[](_tradeIdTracker.current() - 1);
        for (uint256 i = 0; i < trades.length; i++) {
            trades[i] = _trades[i + 1];
        }
        return trades;
    }

    function grantWriterRole(address to) external {
        grantRole(DATA_WRITER, to);
    }

}
