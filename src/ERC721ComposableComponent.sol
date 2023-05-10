// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./interfaces/IERC721ComposableComponent.sol";
import "./common/ERC721Common.sol";

/// @title ERC721ComposableComponent
/// @author @eldief
/// @notice Contract defining base functionalities for ERC721 Composable-Component
/// @dev Abstract contract providing internal methods to expose via external aliases
///      `Contract Configuration` and `Component Registry` expose custom data, customizable by implementations
///      Custom `Token Configuration` layout:
///      - [0..63]    `Seed`
///      - [64..255]  `Custom data`
abstract contract ERC721ComposableComponent is IERC721ComposableComponent, ERC721Common {
    using Base64 for bytes;
    using LibString for uint256;
    using DynamicBufferLib for DynamicBufferLib.DynamicBuffer;

    /*
        ┌─┐┬  ┬┌─┐┌┐┌┌┬┐┌─┐
        ├┤ └┐┌┘├┤ │││ │ └─┐
        └─┘ └┘ └─┘┘└┘ ┴ └─┘ */
    /// @notice `ExpansionSet` event
    /// @dev `ComponentSet` event signature:
    ///      `keccak256(bytes("ComponentSet(uint256,uint256,uint8,uint16)"))`
    event ComponentSet(uint256 indexed tokenId, uint256 indexed slotId, uint8 componentId, uint16 itemId);

    bytes32 internal constant _COMPONENT_SET_SIGNATURE =
        0xeec0cb6f63a7a03e6105cede2e7d90cb184e6ee94557e3c57d8535c67bd13c7b;

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
        ┌─┐┌─┐┌┐┌┌─┐┌┬┐   ┬┌┬┐┌┬┐┬ ┬┌┬┐┌─┐┌┐ ┬  ┌─┐┌─┐
        │  │ ││││└─┐ │ ───││││││││ │ │ ├─┤├┴┐│  ├┤ └─┐
        └─┘└─┘┘└┘└─┘ ┴    ┴┴ ┴┴ ┴└─┘ ┴ ┴ ┴└─┘┴─┘└─┘└─┘  */
    /// @dev Packed configuration slot 0 offset
    uint8 internal constant _COMPONENT_SLOT_0 = 64;

    /// @dev Packed configuration slot 1 offset
    uint8 internal constant _COMPONENT_SLOT_1 = 88;

    /// @dev Packed configuration slot 2 offset
    uint8 internal constant _COMPONENT_SLOT_2 = 112;

    /// @dev Packed configuration slot 3 offset
    uint8 internal constant _COMPONENT_SLOT_3 = 136;

    /// @dev Packed configuration slot 4 offset
    uint8 internal constant _COMPONENT_SLOT_4 = 160;

    /// @dev Packed configuration slot 5 offset
    uint8 internal constant _COMPONENT_SLOT_5 = 184;

    /// @dev Packed configuration slot 6 offset
    uint8 internal constant _COMPONENT_SLOT_6 = 208;

    /// @dev Packed configuration slot 7 offset
    uint8 internal constant _COMPONENT_SLOT_7 = 232;

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
    /// @param slot uint256 Slot number
    /// @return componentId uint256 Unpacked `Component ID`
    /// @return itemId uint256 Unpacked `Item ID`
    function _getComponent(uint256 tokenId, uint8 slot)
        internal
        view
        existingToken(tokenId)
        returns (uint256 componentId, uint256 itemId)
    {
        assembly {
            // configuration = _configurations[tokenId];
            mstore(0, tokenId)
            mstore(0x20, _configurations.slot)
            let configuration := sload(keccak256(0, 0x40))

            // componentId = configuration.unpackUInt8(slot);
            componentId := and(shr(slot, configuration), 0xFF)

            // itemId = configuration.unpackUInt16(slot + 8);
            itemId := and(shr(add(slot, 8), configuration), 0xFFFF)
        }
    }

    /// @notice Returns `Component Address` for `Component ID`
    /// @dev Each component data is packed in a single word, see `PackingLib`
    /// @param componentId uint256 Component ID
    /// @return componentAddress address Unpacked `Component Address`
    function _getComponentAddress(uint256 componentId) internal view returns (address componentAddress) {
        assembly {
            // component = _components[expansionId];
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
    /// @param slot uint256 Slot offset
    /// @param componentId uint8 Component ID
    /// @param itemId uint16 Item ID
    function _setComponent(uint256 tokenId, uint8 slot, uint8 componentId, uint16 itemId)
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
            configuration := or(configuration, shl(slot, componentId))

            // configuration.packUInt16(slot + 8, itemId);
            configuration := and(configuration, not(shl(add(slot, 8), 0xFFFF)))
            configuration := or(configuration, shl(add(slot, 8), itemId))

            // _tokenConfiguration[tokenId] = configuration;
            sstore(slotHash, configuration)

            // emit MetadataUpdate(tokenId);
            mstore(0, tokenId)
            log1(0, 0x20, _METADATA_UPDATE_SIGNATURE)

            // emit ComponentSet(tokenId, slotId, componentId, itemId);
            mstore(0, componentId)
            mstore(0x20, itemId)
            let slotId := div(sub(slot, 64), 24) // slotId = (slot - 64) / 24
            log3(0, 0x40, _COMPONENT_SET_SIGNATURE, tokenId, slotId)
        }
    }

    /// @notice Register component data
    /// @dev Each component data is packed in a single word, see `PackingLib`
    ///      See `Solady.Ownable.onlyOwner` modifier for reverts
    /// @param componentId uint8 Component ID
    /// @param componentAddress address Component address
    function _setComponentAddress(uint8 componentId, address componentAddress) internal onlyOwner {
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
        DynamicBufferLib.DynamicBuffer memory buffer1;
        DynamicBufferLib.DynamicBuffer memory buffer2;

        _renderComponents(buffer1, buffer2, tokenId, _configurations[tokenId]);

        ComponentRenderRequest memory request = _onRendering(tokenId);
        _onRender(buffer1, buffer2, request);
        _onRenderedInternal(buffer1, buffer2);

        DynamicBufferLib.DynamicBuffer memory tokenURIBuffer;
        tokenURIBuffer.append("data:application/json,{");
        tokenURIBuffer.append('"name":"', bytes(name()), '",');
        tokenURIBuffer.append('"description":"', bytes(description()), '",');
        tokenURIBuffer.append('"image":"data:image/svg+xml;base64,', bytes(buffer1.data.encode()), '",');
        tokenURIBuffer.append('"attributes":[', buffer2.data, "]}");

        return string(abi.encodePacked("data:application/json;base64,", tokenURIBuffer.data.encode()));
    }

    /// @notice Render all `ERC721Components`
    /// @dev Buffers are passed by reference to save gas while appending data
    ///      Uses `_onComponentRendered` hook to deserialize `ComponentRenderResponse`
    /// @param buffer1 DynamicBufferLib.DynamicBuffer Buffer
    /// @param buffer2 DynamicBufferLib.DynamicBuffer Buffer
    /// @param tokenId uint256 Token ID
    /// @param configuration uint256 Unpacked component configuration
    function _renderComponents(
        DynamicBufferLib.DynamicBuffer memory buffer1,
        DynamicBufferLib.DynamicBuffer memory buffer2,
        uint256 tokenId,
        uint256 configuration
    ) private view {
        ComponentRenderResponse memory response;

        unchecked {
            for (uint256 i; i < 8; ++i) {
                uint256 itemId;
                uint256 componentId;

                assembly {
                    itemId := and(shr(add(8, add(64, mul(i, 24))), configuration), 0xFFFF)
                    componentId := and(shr(add(64, mul(i, 24)), configuration), 0xFF)
                }

                address tokenOwner = ownerOf(tokenId);
                address componentAddress = _getComponentAddress(componentId);

                if (componentAddress != address(0)) {
                    response = _renderComponent(tokenOwner, componentAddress, itemId, i);

                    if (response.data.length > 0) {
                        _onComponentRendered(buffer1, buffer2, response);
                    }
                }
            }
        }
    }

    /// @notice Render `ERC721Component`
    /// @dev Gas for checking component validity and ownership is delegated to view functions, e.g. `ERC721.tokenURI`.
    ///      This save gas on `ERC721.transferFrom`, `ERC721.safeFransferFrom` and `ERC721Composable.setComponent`.
    ///      Uses `_onComponentRendering` hook to serialize `ComponentRenderRequest`
    /// @param tokenOwner address ERC721 owner of `tokenId`
    /// @param componentAddress address Component address
    /// @param itemId uint256 Component item ID
    /// @param slotId uint256 Component slot ID
    /// @return response ComponentRenderResponse
    function _renderComponent(address tokenOwner, address componentAddress, uint256 itemId, uint256 slotId)
        private
        view
        returns (ComponentRenderResponse memory response)
    {
        // Try-catch block: having no check on setting components could revert when `itemId` is invalid
        try IERC721A(componentAddress).ownerOf(itemId) returns (address itemOwner) {
            if (tokenOwner == itemOwner) {
                ComponentRenderRequest memory request = _onComponentRendering(itemId);
                ComponentRenderResponse memory _response = IERC721Component(componentAddress).renderExternally(request);

                if (slotId == response.slotId) {
                    response = _response;
                }
            }
        } catch { /* pass */ }
    }

    /// @notice Component render function
    /// @dev Entry point for `ERC721Composable._renderComponents`
    ///      Has to be overridden by Component Implementation
    /// @param request ComponentRenderRequest Component render request
    /// @return response ComponentRenderResponse Component render response
    function renderExternally(ComponentRenderRequest memory request)
        external
        view
        returns (ComponentRenderResponse memory)
    {
        DynamicBufferLib.DynamicBuffer memory buffer1;
        DynamicBufferLib.DynamicBuffer memory buffer2;

        _onRender(buffer1, buffer2, request);

        return _onRenderedExternal(buffer1, buffer2);
    }

    /*
        ┬ ┬┌─┐┌─┐┬┌─┌─┐
        ├─┤│ ││ │├┴┐└─┐
        ┴ ┴└─┘└─┘┴ ┴└─┘ */
    /// @notice On rendering hook
    /// @dev Executed before rendering
    ///      Has to be overridden with custom behaviour for serializing `ComponentRenderRequest`
    /// @param itemId uint256 Componet item ID
    /// @return request ComponentRenderRequest Component render request
    function _onRendering(uint256 itemId) internal view virtual returns (ComponentRenderRequest memory request);

    /// @notice On render hook
    /// @dev Executed while rendering
    ///      Has to be overridden with custom behaviour for deserializing `ComponentRenderRequest` and writing to buffers
    /// @param buffer1 DynamicBufferLib.DynamicBuffer Buffer
    /// @param buffer2 DynamicBufferLib.DynamicBuffer Buffer
    /// @param request ComponentRenderRequest Component render request
    function _onRender(
        DynamicBufferLib.DynamicBuffer memory buffer1,
        DynamicBufferLib.DynamicBuffer memory buffer2,
        ComponentRenderRequest memory request
    ) internal view virtual;

    /// @notice On rendered hook for internal calls
    /// @dev Executed after rendering internally
    ///      Has to be overridden with custom behaviour writing to buffers
    /// @param buffer1 DynamicBufferLib.DynamicBuffer Buffer
    /// @param buffer2 DynamicBufferLib.DynamicBuffer Buffer
    function _onRenderedInternal(
        DynamicBufferLib.DynamicBuffer memory buffer1,
        DynamicBufferLib.DynamicBuffer memory buffer2
    ) internal view virtual;

    /// @notice On rendered hook for external calls
    /// @dev Executed after rendering externally
    ///      Has to be overridden with custom behaviour for serializing `ComponentRenderResponse`
    /// @param buffer1 DynamicBufferLib.DynamicBuffer Buffer
    /// @param buffer2 DynamicBufferLib.DynamicBuffer Buffer
    /// @return response ComponentRenderResponse Component render response
    function _onRenderedExternal(
        DynamicBufferLib.DynamicBuffer memory buffer1,
        DynamicBufferLib.DynamicBuffer memory buffer2
    ) internal view virtual returns (ComponentRenderResponse memory response);

    /// @notice On component rendering hook
    /// @dev Executed before rendering a component
    ///      Has to be overridden with custom behaviour for serializing `ComponentRenderRequest`
    /// @param itemId uint256 Componet item ID
    /// @return request ComponentRenderRequest Component render request
    function _onComponentRendering(uint256 itemId)
        internal
        view
        virtual
        returns (ComponentRenderRequest memory request);

    /// @notice On component rendered hook
    /// @dev Executed after rendering a component
    ///      Has to be overridden with custom behaviour for deserializing `ComponentRenderResponse` and writing to buffers
    /// @param buffer1 DynamicBufferLib.DynamicBuffer Buffer
    /// @param buffer2 DynamicBufferLib.DynamicBuffer Buffer
    /// @param response ComponentRenderResponse Component render response
    function _onComponentRendered(
        DynamicBufferLib.DynamicBuffer memory buffer1,
        DynamicBufferLib.DynamicBuffer memory buffer2,
        ComponentRenderResponse memory response
    ) internal view virtual;
}
