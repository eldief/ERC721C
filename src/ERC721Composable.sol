// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@solady/auth/Ownable.sol";
import "@ERC721A/contracts/ERC721A.sol";

/// @title ERC721Composable
/// @author @eldief
/// @notice Contract defining base functionalities for ERC721 Composable
/// @dev Abstract contract providing internal methods to expose via external aliases
///      `Contract Configuration` and `Expansion Registry` expose custom data, customizable by implementations
///      Uses `ERC721A` for `ERC721` implementation
///      Uses `Solady.Ownable` for ownership
abstract contract ERC721Composable is ERC721A, Ownable {
    /*
        ┌─┐┬─┐┬─┐┌─┐┬─┐┌─┐
        ├┤ ├┬┘├┬┘│ │├┬┘└─┐
        └─┘┴└─┴└─└─┘┴└─└─┘  */
    /// @notice `InvalidTokenId` error
    error InvalidTokenId();

    /*
        ┌─┐┬  ┬┌─┐┌┐┌┌┬┐┌─┐
        ├┤ └┐┌┘├┤ │││ │ └─┐
        └─┘ └┘ └─┘┘└┘ ┴ └─┘ */
    /// @notice `IERC4906.BatchMetadataUpdate` event
    /// @dev `IERC4906.BatchMetadataUpdate` event signature:
    ///      `keccak256(bytes("BatchMetadataUpdate(uint256,uint256)"))`
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);

    bytes32 private constant _BATCH_METADATA_UPDATE_SIGNATURE =
        0x6bd5c950a8d8df17f772f5af37cb3655737899cbf903264b9795592da439661c;

    /// @notice `ExpansionSet` event
    /// @dev `ExpansionSet` event signature:
    ///      `keccak256(bytes("ExpansionSet(uint256,uint256,uint8,uint16)"))`
    event ExpansionSet(uint256 indexed tokenId, uint256 indexed slotId, uint8 expansionId, uint16 itemId);

    bytes32 private constant _EXPANSION_SET_SIGNATURE =
        0x78386ac0424c1a99f47851cbf6ebb94b0d46ca78caf4d51096c1ffaa8ca1662b;

    /// @notice `IERC4906.MetadataUpdate` event
    /// @dev `IERC4906.MetadataUpdate` event signature:
    ///      `keccak256(bytes("MetadataUpdate(uint256)"))`
    event MetadataUpdate(uint256 _tokenId);

    bytes32 private constant _METADATA_UPDATE_SIGNATURE =
        0xf8e1a15aba9398e019f0b49df1a4fde98ee17ae345cb5f6b5e2c27f5033e8ce7;

    /*
        ┌─┐┌┬┐┌─┐┬─┐┌─┐┌─┐┌─┐
        └─┐ │ │ │├┬┘├─┤│ ┬├┤ 
        └─┘ ┴ └─┘┴└─┴ ┴└─┘└─┘   */
    /// @notice Contract configuration
    /// @dev Packed `Contract Configuration` to be customized by implementations
    ///      Layout:
    ///      - [0..255]   `Custom data`
    uint256 internal _configuration;

    /// @notice Expansions registry
    /// @dev Mapping from `Expansion ID` to packed `Expansion Configuration` data
    ///      Packed configuration to be customized by implementations
    ///      Layout:
    ///      - [0..159]   `Expansion address`
    ///      - [160..255] `Custom data`
    mapping(uint8 => uint256) internal _expansions;

    /// @dev Mapping from `Token ID` to packed `Token Configuration` data
    ///      See `TokenConfigurationLib` for pack / unpack methods
    ///      Layout:
    ///      - [0..63]    `Seed`
    ///      - [64..71]   `Slot 0 expansion id`
    ///      - [72..87]   `Slot 0 item id`
    ///      - [88..65]   `Slot 1 expansion id`
    ///      - [96..111]  `Slot 1 item id`
    ///      - [112..119] `Slot 2 expansion id`
    ///      - [120..135] `Slot 2 item id`
    ///      - [136..143] `Slot 3 expansion id`
    ///      - [144..159] `Slot 3 item id`
    ///      - [160..167] `Slot 4 expansion id`
    ///      - [168..183] `Slot 4 item id`
    ///      - [184..191] `Slot 5 expansion id`
    ///      - [192..207] `Slot 5 item id`
    ///      - [208..215] `Slot 6 expansion id`
    ///      - [216..231] `Slot 6 item id`
    ///      - [232..239] `Slot 7 expansion id`
    ///      - [240..255] `Slot 7 item id`
    mapping(uint256 => uint256) internal _configurations;

    /*
        ┌─┐┌─┐┌┐┌┌─┐┌┬┐   ┬┌┬┐┌┬┐┬ ┬┌┬┐┌─┐┌┐ ┬  ┌─┐┌─┐
        │  │ ││││└─┐ │ ───││││││││ │ │ ├─┤├┴┐│  ├┤ └─┐
        └─┘└─┘┘└┘└─┘ ┴    ┴┴ ┴┴ ┴└─┘ ┴ ┴ ┴└─┘┴─┘└─┘└─┘  */
    /// @dev Packed configuration slot 0 offset
    uint8 internal constant _EXPANSION_SLOT_0 = 64;

    /// @dev Packed configuration slot 1 offset
    uint8 internal constant _EXPANSION_SLOT_1 = 88;

    /// @dev Packed configuration slot 2 offset
    uint8 internal constant _EXPANSION_SLOT_2 = 112;

    /// @dev Packed configuration slot 3 offset
    uint8 internal constant _EXPANSION_SLOT_3 = 136;

    /// @dev Packed configuration slot 4 offset
    uint8 internal constant _EXPANSION_SLOT_4 = 160;

    /// @dev Packed configuration slot 5 offset
    uint8 internal constant _EXPANSION_SLOT_5 = 184;

    /// @dev Packed configuration slot 6 offset
    uint8 internal constant _EXPANSION_SLOT_6 = 208;

    /// @dev Packed configuration slot 7 offset
    uint8 internal constant _EXPANSION_SLOT_7 = 232;

    /*
        ┌─┐┌─┐┌┐┌┌─┐┌┬┐┬─┐┬ ┬┌─┐┌┬┐┌─┐┬─┐
        │  │ ││││└─┐ │ ├┬┘│ ││   │ │ │├┬┘
        └─┘└─┘┘└┘└─┘ ┴ ┴└─└─┘└─┘ ┴ └─┘┴└─   */
    /// @notice Constructor
    /// @dev Initialize `ERC721A` with `name_` and `symbol_`
    ///      Initialize ownership via `Solady.Ownable`
    constructor(string memory name_, string memory symbol_, address owner_) ERC721A(name_, symbol_) {
        _initializeOwner(owner_);
    }

    /*
        ┌┬┐┌─┐┌┬┐┬┌─┐┬┌─┐┬─┐┌─┐
        ││││ │ │││├┤ │├┤ ├┬┘└─┐
        ┴ ┴└─┘─┴┘┴└  ┴└─┘┴└─└─┘ */
    /// @notice Modifier to allow only existing `tokenId` to access functionality
    /// @dev Reverts with `InvalidTokenId` when `tokenId` doesn't exist
    modifier existingToken(uint256 tokenId) {
        if (!_exists(tokenId)) {
            revert InvalidTokenId();
        }
        _;
    }

    /// @notice Modifier to allow only token owner to access functionality
    /// @dev Reverts with `OwnerQueryForNonexistentToken` when token doesn't exist
    ///      Reverts with `Unauthorized` when caller is not token owner
    modifier tokenOwnerOnly(uint256 tokenId) {
        if (msg.sender != ownerOf(tokenId)) {
            revert Unauthorized();
        }
        _;
    }

    /*
        ┌─┐┌─┐┌┬┐┌┬┐┌─┐┬─┐┌─┐
        │ ┬├┤  │  │ ├┤ ├┬┘└─┐
        └─┘└─┘ ┴  ┴ └─┘┴└─└─┘   */
    /// @notice Returns `Expansion ID` and `Item ID` expansion data
    /// @dev Each expansion data is packed in a single word, see `PackingLib`
    ///      See `existingToken` modifier for reverts
    /// @param tokenId uint256 Token ID
    /// @param slot uint256 Slot number
    /// @return expansionId uint256 Unpacked `Expansion ID`
    /// @return itemId uint256 Unpacked `Item ID`
    function _getExpansion(uint256 tokenId, uint8 slot)
        internal
        view
        existingToken(tokenId)
        returns (uint256 expansionId, uint256 itemId)
    {
        assembly {
            // configuration = _configurations[tokenId];
            mstore(0, tokenId)
            mstore(0x20, _configurations.slot)
            let configuration := sload(keccak256(0, 0x40))

            // expansionId = configuration.unpackUInt8(slot);
            expansionId := and(shr(slot, configuration), 0xFF)

            // itemId = configuration.unpackUInt16(slot + 8);
            itemId := and(shr(add(slot, 8), configuration), 0xFFFF)
        }
    }

    /// @notice Returns `Expansion Address` for `Expansion ID`
    /// @dev Each expansion data is packed in a single word, see `PackingLib`
    /// @param expansionId uint256 Expansion ID
    /// @return expansionAddress address Unpacked `Expansion Address`
    function _getExpansionAddress(uint8 expansionId) internal view returns (address expansionAddress) {
        assembly {
            // expansion = _expansions[expansionId];
            mstore(0, expansionId)
            mstore(0x20, _expansions.slot)
            let expansion := sload(keccak256(0, 0x40))

            // expansionAddress = expansion.unpackAddress(0);
            expansionAddress := and(expansion, 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF)
        }
    }

    /*
        ┌─┐┌─┐┌┬┐┌┬┐┌─┐┬─┐┌─┐
        └─┐├┤  │  │ ├┤ ├┬┘└─┐
        └─┘└─┘ ┴  ┴ └─┘┴└─└─┘   */
    /// @notice Set expansion data
    /// @dev Each expansion data is packed in a single word, see `PackingLib`
    ///      Delegates verification gas usage to `tokenURI` view function
    ///      See `tokenOwnerOnly` modifier for reverts
    ///      Emit `ERC4906.MetadataUpdate` event
    ///      Emit `ExpansionSet` event
    /// @param tokenId uint256 Token ID
    /// @param slot uint256 Slot offset
    /// @param expansionId uint8 Expansion ID
    /// @param itemId uint16 Item ID
    function _setExpansion(uint256 tokenId, uint8 slot, uint8 expansionId, uint16 itemId)
        internal
        tokenOwnerOnly(tokenId)
    {
        assembly {
            // configuration = _configurations[tokenId]
            mstore(0, tokenId)
            mstore(0x20, _configurations.slot)
            let slotHash := keccak256(0, 0x40)
            let configuration := sload(slotHash)

            // configuration.packUInt8(slot, expansionId);
            configuration := and(configuration, not(shl(slot, 0xFF)))
            configuration := or(configuration, shl(slot, expansionId))

            // configuration.packUInt16(slot + 8, itemId);
            configuration := and(configuration, not(shl(add(slot, 8), 0xFFFF)))
            configuration := or(configuration, shl(add(slot, 8), itemId))

            // _tokenConfiguration[tokenId] = configuration;
            sstore(slotHash, configuration)

            // emit MetadataUpdate(tokenId);
            mstore(0, tokenId)
            log1(0, 0x20, _METADATA_UPDATE_SIGNATURE)

            // emit ExpansionSet(tokenId, slotId, expansionId, itemId);
            mstore(0, expansionId)
            mstore(0x20, itemId)
            let slotId := div(sub(slot, 64), 24) // slotId = (slot - 64) / 24
            log3(0, 0x40, _EXPANSION_SET_SIGNATURE, tokenId, slotId)
        }
    }

    /// @notice Register expansion data
    /// @dev Each expansion data is packed in a single word, see `PackingLib`
    ///      See `Solady.Ownable.onlyOwner` modifier for reverts
    /// @param expansionAddress address Expansion address
    function _setExpansionAddress(uint8 expansionId, address expansionAddress) internal onlyOwner {
        assembly {
            // expansion = _expansions[expansionId];
            mstore(0, expansionId)
            mstore(0x20, _expansions.slot)
            let slotHash := keccak256(0, 0x40)
            let expansion := sload(slotHash)

            // expansion.packAddress(0, expansionAddress);
            expansion := and(expansion, not(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF))
            expansion := or(expansion, expansionAddress)

            // _expansions[expansionId] = expansion;
            sstore(slotHash, expansion)

            // emit BatchMetadataUpdate(0, type(uint256).max);
            mstore(0, 0)
            mstore(0x20, sub(0, 1))
            log1(0, 0x40, _BATCH_METADATA_UPDATE_SIGNATURE)
        }
    }

    /*
        ┌─┐┬  ┬┌─┐┬─┐┬─┐┬┌┬┐┌─┐┌─┐
        │ │└┐┌┘├┤ ├┬┘├┬┘│ ││├┤ └─┐
        └─┘ └┘ └─┘┴└─┴└─┴─┴┘└─┘└─┘  */
    /// @notice `ERC721A._burn` override
    /// @dev Clear storage for tokenId
    ///      See `ERC721A._mint` for more informations
    function _burn(uint256 tokenId, bool approvalCheck) internal virtual override {
        super._burn(tokenId, approvalCheck);

        assembly {
            // delete _configurations[tokenId];
            mstore(0, tokenId)
            mstore(0x20, _configurations.slot)
            sstore(keccak256(0, 0x40), 0)
        }
    }

    /// @notice `ERC721A._mint` override
    /// @dev Compute and set PRNG packed `seed` for on-chain generated svgs
    ///      See `PackingLib` for pack informations
    ///      See `ERC721A._mint` for more informations
    /// @param to address Recipient
    /// @param quantity uint256 Quantity to be minted
    function _mint(address to, uint256 quantity) internal virtual override {
        uint256 tokenId = _nextTokenId();

        assembly {
            // for(uint256 i; i < quantity;)
            for { let i } lt(i, quantity) { i := add(i, 1) } {
                // seed = uint64(uint256(keccak256(abi.encode(tokenId, msg.sender))));
                mstore(0, tokenId)
                mstore(0x20, caller())
                let seed := and(keccak256(0, 0x40), 0xFFFFFFFFFFFFFFFF)

                // _configurations[tokenId] = seed;
                mstore(0x20, _configurations.slot)
                let slotHash := keccak256(0, 0x40)
                sstore(slotHash, seed)

                // unchecked { ++tokenId; }
                tokenId := add(tokenId, 1)
            }
        }

        super._mint(to, quantity);
    }

    /// @notice `ERC721A._startTokenId` override
    /// @dev Set first `tokenId` to 1
    ///      See `ERC721A._startTokenId` for more informations
    function _startTokenId() internal pure virtual override returns (uint256) {
        return 1;
    }
}
