// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./interfaces/IERC721Component.sol";
import "./interfaces/IERC721Composable.sol";
import "./common/ERC721Common.sol";

/// @title ERC721Composable
/// @author @eldief
/// @notice Contract defining base functionalities for ERC721 Composable
/// @dev Layouts:
///      - _components -> `Component Registry`
///        - [0..159]   `Component address`
///        - [160..255] `Custom data`
///
///      - _configuration -> `Contract Configuration`
///        - [0..255]   `Custom data`
///
///      - _configurations -> `Token Configuration`
///        - [0..63]    `Seed`
///        - [64..71]   `Slot 0 component id`
///        - [72..87]   `Slot 0 item id`
///        - [88..65]   `Slot 1 component id`
///        - [96..111]  `Slot 1 item id`
///        - [112..119] `Slot 2 component id`
///        - [120..135] `Slot 2 item id`
///        - [136..143] `Slot 3 component id`
///        - [144..159] `Slot 3 item id`
///        - [160..167] `Slot 4 component id`
///        - [168..183] `Slot 4 item id`
///        - [184..191] `Slot 5 component id`
///        - [192..207] `Slot 5 item id`
///        - [208..215] `Slot 6 component id`
///        - [216..231] `Slot 6 item id`
///        - [232..239] `Slot 7 component id`
///        - [240..255] `Slot 7 item id`
abstract contract ERC721Composable is IERC721Composable, ERC721Common {
    using Base64 for bytes;
    using DynamicBufferLib for DynamicBufferLib.DynamicBuffer;

    /*
        ┌─┐┬─┐┬─┐┌─┐┬─┐┌─┐
        ├┤ ├┬┘├┬┘│ │├┬┘└─┐
        └─┘┴└─┴└─└─┘┴└─└─┘  */
    /// @notice `InvalidSlotId` error
    error InvalidSlotId();

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

    /// @notice `ComponentSet` event
    /// @dev `ComponentSet` event signature:
    ///      `keccak256(bytes("ComponentSet(uint256,uint256,uint8,uint16)"))`
    event ComponentSet(uint256 indexed tokenId, uint256 indexed slotId, uint8 componentId, uint16 itemId);

    bytes32 internal constant _COMPONENT_SET_SIGNATURE =
        0xeec0cb6f63a7a03e6105cede2e7d90cb184e6ee94557e3c57d8535c67bd13c7b;

    /// @notice `IERC4906.MetadataUpdate` event
    /// @dev `IERC4906.MetadataUpdate` event signature:
    ///      `keccak256(bytes("MetadataUpdate(uint256)"))`
    event MetadataUpdate(uint256 _tokenId);

    bytes32 internal constant _METADATA_UPDATE_SIGNATURE =
        0xf8e1a15aba9398e019f0b49df1a4fde98ee17ae345cb5f6b5e2c27f5033e8ce7;

    /*
        ┌─┐┌┬┐┌─┐┬─┐┌─┐┌─┐┌─┐
        └─┐ │ │ │├┬┘├─┤│ ┬├┤ 
        └─┘ ┴ └─┘┴└─┴ ┴└─┘└─┘   */
    /// @notice Component registry
    /// @dev Mapping from `Component ID` to packed `Component Configuration` data
    ///      Packed configuration to be customized by implementations
    ///      Layout:
    ///      - [0..159]   `Component address`
    ///      - [160..255] `Custom data`
    mapping(uint8 => uint256) internal _components;

    /*
        ┌─┐┌─┐┌┐┌┌─┐┌┬┐┬─┐┬ ┬┌─┐┌┬┐┌─┐┬─┐
        │  │ ││││└─┐ │ ├┬┘│ ││   │ │ │├┬┘
        └─┘└─┘┘└┘└─┘ ┴ ┴└─└─┘└─┘ ┴ └─┘┴└─   */
    /// @notice Constructor
    /// @dev Initialize `ERC721A` with `name_` and `symbol_`
    ///      Initialize ownership via `Solady.Ownable`
    constructor(string memory name_, string memory symbol_) ERC721Common(name_, symbol_) {}

    /*
        ┌─┐┌─┐┌┬┐┌┬┐┌─┐┬─┐┌─┐
        │ ┬├┤  │  │ ├┤ ├┬┘└─┐
        └─┘└─┘ ┴  ┴ └─┘┴└─└─┘   */
    /// @notice Returns `Component ID` and `Item ID` component data
    /// @dev Each component data is packed in a single word, see `PackingLib`
    ///      See `existingToken` modifier for reverts
    /// @param tokenId uint256 Token ID
    /// @param slotId uint8 Slot ID
    /// @return componentId uint256 Unpacked `Component ID`
    /// @return itemId uint256 Unpacked `Item ID`
    function getComponent(uint256 tokenId, uint8 slotId)
        public
        view
        existingToken(tokenId)
        returns (uint256 componentId, uint256 itemId)
    {
        assembly {
            // configuration = _configurations[tokenId]
            mstore(0, tokenId)
            mstore(0x20, _configurations.slot)
            let slotHash := keccak256(0, 0x40)
            let configuration := sload(slotHash)

            // componentId = configuration.unpackUInt8(64 + slotId * 24);
            let offset := add(64, mul(24, slotId))
            componentId := and(shr(offset, configuration), 0xFF)

            // itemId = configuration.unpackUInt16(72 + slotId * 24);
            offset := add(8, offset)
            itemId := and(shr(offset, configuration), 0xFFFF)
        }
    }

    /// @notice Returns `Component Address` for `Component ID`
    /// @dev Each component data is packed in a single word, see `PackingLib`
    /// @param componentId uint256 Component ID
    /// @return componentAddress address Unpacked `Component Address`
    function getComponentAddress(uint256 componentId) public view returns (address componentAddress) {
        assembly {
            // component = _components[componentId];
            mstore(0, componentId)
            mstore(0x20, _components.slot)
            let component := sload(keccak256(0, 0x40))

            // componentAddress = component.unpackAddress(0);
            componentAddress := and(component, 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF)
        }
    }

    /*
        ┌─┐┌─┐┌┬┐┌┬┐┌─┐┬─┐┌─┐
        └─┐├┤  │  │ ├┤ ├┬┘└─┐
        └─┘└─┘ ┴  ┴ └─┘┴└─└─┘   */
    /// @notice Set component data
    /// @dev Each component data is packed in a single word, see `PackingLib`
    ///      Delegates verification gas usage to `tokenURI` view function
    ///      See `tokenOwnerOnly` modifier for reverts
    ///      Emit `ERC4906.MetadataUpdate` event
    ///      Emit `ComponentSet` event
    /// @param tokenId uint256 Token ID
    /// @param slotId uint256 Slot ID
    /// @param componentId uint8 Component ID
    /// @param itemId uint16 Item ID
    function setComponent(uint256 tokenId, uint8 slotId, uint8 componentId, uint16 itemId)
        public
        tokenOwnerOnly(tokenId)
    {
        if (slotId > 7) {
            revert InvalidSlotId();
        }
        assembly {
            // configuration = _configurations[tokenId]
            mstore(0, tokenId)
            mstore(0x20, _configurations.slot)
            let slotHash := keccak256(0, 0x40)
            let configuration := sload(slotHash)

            // configuration.packUInt8(64 + slotId * 24, componentId);
            let offset := add(64, mul(24, slotId))
            configuration := and(configuration, not(shl(offset, 0xFF)))
            configuration := or(configuration, shl(offset, componentId))

            // configuration.packUInt16(72 + slotId * 24, itemId);
            offset := add(8, offset)
            configuration := and(configuration, not(shl(offset, 0xFFFF)))
            configuration := or(configuration, shl(offset, itemId))

            // _tokenConfiguration[tokenId] = configuration;
            sstore(slotHash, configuration)

            // emit MetadataUpdate(tokenId);
            mstore(0, tokenId)
            log1(0, 0x20, _METADATA_UPDATE_SIGNATURE)

            // emit ComponentSet(tokenId, slotId, componentId, itemId);
            mstore(0, componentId)
            mstore(0x20, itemId)

            log3(0, 0x40, _COMPONENT_SET_SIGNATURE, tokenId, slotId)
        }
    }

    /// @notice Register component data
    /// @dev Each component data is packed in a single word, see `PackingLib`
    ///      See `Solady.Ownable.onlyOwner` modifier for reverts
    /// @param componentId uint8 Component ID
    /// @param componentAddress address Component address
    function setComponentAddress(uint8 componentId, address componentAddress) public onlyOwner {
        assembly {
            // component = _components[componentId];
            mstore(0, componentId)
            mstore(0x20, _components.slot)
            let slotHash := keccak256(0, 0x40)
            let component := sload(slotHash)

            // component.packAddress(0, componentAddress);
            component := and(component, not(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF))
            component := or(component, componentAddress)

            // _components[componentId] = component;
            sstore(slotHash, component)

            // emit BatchMetadataUpdate(0, type(uint256).max);
            mstore(0, 0)
            mstore(0x20, sub(0, 1))
            log1(0, 0x40, _BATCH_METADATA_UPDATE_SIGNATURE)
        }
    }

    /*
        ┬─┐┌─┐┌┐┌┌┬┐┌─┐┬─┐┬┌┐┌┌─┐
        ├┬┘├┤ │││ ││├┤ ├┬┘│││││ ┬
        ┴└─└─┘┘└┘─┴┘└─┘┴└─┴┘└┘└─┘   */
    /// @notice Render a token
    /// @dev On-chain render for `ERC721Component`
    ///      Has to be overridden by Component Implementation
    ///      Reverts with `InvalidTokenId` when `tokenId` doesn't exist
    /// @param tokenId uint256 Token ID
    /// @return uri string Token URI
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override(IERC721A, ERC721A)
        existingToken(tokenId)
        returns (string memory)
    {
        DynamicBufferLib.DynamicBuffer memory image;
        DynamicBufferLib.DynamicBuffer memory animation;
        DynamicBufferLib.DynamicBuffer memory attributes;

        ComponentRenderRequest memory request = _beforeRender(tokenId);
        _renderComponents(image, animation, attributes, request, tokenId);
        _onRender(image, animation, attributes, request);
        _afterRender(image, animation, attributes);

        DynamicBufferLib.DynamicBuffer memory json;
        json.append('{"name":"', bytes(name()), '"');

        if (bytes(description()).length > 0) {
            json.append(',"description":"', bytes(description()), '"');
        }
        if (image.data.length > 0) {
            json.append(',"image":"data:image/svg+xml;base64,', bytes(image.data.encode()), '"');
        }
        if (animation.data.length > 0) {
            json.append(',"animation_url":"', animation.data, '"');
        }
        if (attributes.data.length > 0) {
            json.append(',"attributes":[', attributes.data, "]");
        }
        json.append("}");

        return string(abi.encodePacked("data:application/json;base64,", json.data.encode()));
    }

    /// @notice Render all `ERC721Components`
    /// @dev Buffers are passed by reference to save gas while appending data
    ///      Uses `_afterComponentRender` hook to deserialize `ComponentRenderResponse`
    /// @param image DynamicBufferLib.DynamicBuffer Image buffer
    /// @param animation DynamicBufferLib.DynamicBuffer Animation buffer
    /// @param attributes DynamicBufferLib.DynamicBuffer Attributes buffer
    /// @param request ComponentRenderRequest Component render request
    /// @param tokenId uint256 Token id
    function _renderComponents(
        DynamicBufferLib.DynamicBuffer memory image,
        DynamicBufferLib.DynamicBuffer memory animation,
        DynamicBufferLib.DynamicBuffer memory attributes,
        ComponentRenderRequest memory request,
        uint256 tokenId
    ) private view {
        address owner = ownerOf(tokenId);
        uint256 configuration = _configurations[tokenId];

        unchecked {
            for (uint256 slotId; slotId < 8; ++slotId) {
                _renderComponent(owner, slotId, configuration, request, image, animation, attributes);
            }
        }
    }

    /// @notice Render `ERC721Component`
    /// @dev Gas for checking component validity and ownership is delegated to view functions, e.g. `ERC721.tokenURI`.
    ///      This save gas on `ERC721.transferFrom`, `ERC721.safeFransferFrom` and `ERC721Composable.setComponent`.
    ///      Uses `_beforeComponentRender` hook to serialize `ComponentRenderRequest`
    /// @param owner address ERC721 owner of `tokenId`
    /// @param slotId uint256 Slot id
    /// @param configuration uint256 Packed token configuration
    /// @param request ComponentRenderRequest Component render request
    /// @param image DynamicBufferLib.DynamicBuffer Image buffer
    /// @param animation DynamicBufferLib.DynamicBuffer Animation buffer
    /// @param attributes DynamicBufferLib.DynamicBuffer Attributes buffer
    function _renderComponent(
        address owner,
        uint256 slotId,
        uint256 configuration,
        ComponentRenderRequest memory request,
        DynamicBufferLib.DynamicBuffer memory image,
        DynamicBufferLib.DynamicBuffer memory animation,
        DynamicBufferLib.DynamicBuffer memory attributes
    ) private view {
        bool success;
        uint256 itemId;
        uint256 componentId;
        assembly {
            itemId := and(shr(add(8, add(64, mul(slotId, 24))), configuration), 0xFFFF)
            componentId := and(shr(add(64, mul(slotId, 24)), configuration), 0xFF)
        }

        address componentAddress = getComponentAddress(componentId);

        if (componentAddress != address(0)) {
            _beforeComponentRender(slotId, componentId, request);

            // Try-catch block: having no check on setting components could revert when `itemId` is invalid
            try IERC721A(componentAddress).ownerOf(request.itemId) returns (address itemOwner) {
                if (owner == itemOwner) {
                    try IERC721Component(componentAddress).renderExternally(request) returns (
                        ComponentRenderRequest memory _request
                    ) {
                        if (request.slotId == _request.slotId) {
                            request = _request;
                            success = true;
                        }
                    } catch { /* pass */ }
                }
            } catch { /* pass */ }
        }

        _afterComponentRender(success, image, animation, attributes, request);
    }

    /*
        ┬ ┬┌─┐┌─┐┬┌─┌─┐
        ├─┤│ ││ │├┴┐└─┐
        ┴ ┴└─┘└─┘┴ ┴└─┘ */
    /// @notice On rendering hook
    /// @dev Executed before rendering
    /// @param itemId uint256 Component item ID
    /// @return request ComponentRenderRequest Component render request
    function _beforeRender(uint256 itemId) internal view virtual returns (ComponentRenderRequest memory request);

    /// @notice On render hook
    /// @dev Executed while rendering
    /// @param image DynamicBufferLib.DynamicBuffer Image buffer
    /// @param animation DynamicBufferLib.DynamicBuffer Animation buffer
    /// @param attributes DynamicBufferLib.DynamicBuffer Attributes buffer
    /// @param request ComponentRenderRequest Component render request
    function _onRender(
        DynamicBufferLib.DynamicBuffer memory image,
        DynamicBufferLib.DynamicBuffer memory animation,
        DynamicBufferLib.DynamicBuffer memory attributes,
        ComponentRenderRequest memory request
    ) internal view virtual;

    /// @notice On rendered hook
    /// @dev Executed after rendering
    /// @param image DynamicBufferLib.DynamicBuffer Image buffer
    /// @param animation DynamicBufferLib.DynamicBuffer Animation buffer
    /// @param attributes DynamicBufferLib.DynamicBuffer Attributes buffer
    function _afterRender(
        DynamicBufferLib.DynamicBuffer memory image,
        DynamicBufferLib.DynamicBuffer memory animation,
        DynamicBufferLib.DynamicBuffer memory attributes
    ) internal view virtual;

    /// @notice On component rendering hook
    /// @dev Executed before rendering a component
    /// @param slotId uint256 Slot ID
    /// @param itemId uint256 Component item ID
    /// @param request ComponentRenderRequest Component render request
    function _beforeComponentRender(uint256 slotId, uint256 itemId, ComponentRenderRequest memory request)
        internal
        view
        virtual;

    /// @notice On component rendered hook
    /// @dev Executed after rendering a component
    /// @param success bool Has component been rendered successfully
    /// @param image DynamicBufferLib.DynamicBuffer Image buffer
    /// @param animation DynamicBufferLib.DynamicBuffer Animation buffer
    /// @param attributes DynamicBufferLib.DynamicBuffer Attributes buffer
    /// @param request ComponentRenderRequest Component render request
    function _afterComponentRender(
        bool success,
        DynamicBufferLib.DynamicBuffer memory image,
        DynamicBufferLib.DynamicBuffer memory animation,
        DynamicBufferLib.DynamicBuffer memory attributes,
        ComponentRenderRequest memory request
    ) internal view virtual;
}
