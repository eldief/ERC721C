// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "../interfaces/IERC721Common.sol";
import "@solady/auth/Ownable.sol";
import "@ERC721A/contracts/ERC721A.sol";

/// @title ERC721Common
/// @author @eldief
/// @notice Contract defining base shared functionalities for `ERC721Composable` and `ERC721Component`
/// @dev Abstract contract providing virtual internal methods, overriddable by implementations
///      `Contract Configuration` and `Token Configuration` expose custom data, customizable by implementations
///      Uses `ERC721A` for `ERC721` implementation
///      Uses `Solady.Ownable` for ownership
///      Export `PackingLib` as utility
abstract contract ERC721Common is IERC721Common, ERC721A, Ownable {
    /*
        ┌─┐┬  ┬┌─┐┌┐┌┌┬┐┌─┐
        ├┤ └┐┌┘├┤ │││ │ └─┐
        └─┘ └┘ └─┘┘└┘ ┴ └─┘ */
    /// @notice `IERC4906.BatchMetadataUpdate` event
    /// @dev `IERC4906.BatchMetadataUpdate` event signature:
    ///      `keccak256(bytes("BatchMetadataUpdate(uint256,uint256)"))`
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);

    bytes32 internal constant _BATCH_METADATA_UPDATE_SIGNATURE =
        0x6bd5c950a8d8df17f772f5af37cb3655737899cbf903264b9795592da439661c;

    /// @notice `IERC4906.MetadataUpdate` event
    /// @dev `IERC4906.MetadataUpdate` event signature:
    ///      `keccak256(bytes("MetadataUpdate(uint256)"))`
    event MetadataUpdate(uint256 _tokenId);

    bytes32 internal constant _METADATA_UPDATE_SIGNATURE =
        0xf8e1a15aba9398e019f0b49df1a4fde98ee17ae345cb5f6b5e2c27f5033e8ce7;

    /*
        ┌─┐┬─┐┬─┐┌─┐┬─┐┌─┐
        ├┤ ├┬┘├┬┘│ │├┬┘└─┐
        └─┘┴└─┴└─└─┘┴└─└─┘  */
    /// @notice `InvalidTokenId` error
    error InvalidTokenId();

    /*
        ┌─┐┌┬┐┌─┐┬─┐┌─┐┌─┐┌─┐
        └─┐ │ │ │├┬┘├─┤│ ┬├┤ 
        └─┘ ┴ └─┘┴└─┴ ┴└─┘└─┘   */
    /// @notice Contract configuration
    /// @dev Packed `Contract Configuration` to be customized by implementations
    ///      Layout:
    ///      - [0..255]   `Custom data`
    uint256 internal _configuration;

    /// @dev Mapping from `Token ID` to packed `Token Configuration` data
    ///      See `TokenConfigurationLib` for pack / unpack methods
    ///      Layout:
    ///      - [0..63]    `Seed`
    ///      - [64..255]  `Custom data`
    mapping(uint256 => uint256) internal _configurations;

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
