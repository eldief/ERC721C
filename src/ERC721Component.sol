// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./interfaces/IERC721Component.sol";
import "./common/ERC721Common.sol";

/// @title ERC721Component
/// @author @eldief
/// @notice Contract defining base functionalities for ERC721 Component
/// @dev Layouts:
///      - _configuration -> `Contract Configuration
///        - [0..255]   `Custom data`
///
///      - _configurations -> `Token Configuration`
///        - [0..63]    `Seed`
///        - [64..255]  `Custom data`
abstract contract ERC721Component is IERC721Component, ERC721Common {
    using Base64 for bytes;
    using DynamicBufferLib for DynamicBufferLib.DynamicBuffer;

    /*
        ┌─┐┌─┐┌┐┌┌─┐┌┬┐┬─┐┬ ┬┌─┐┌┬┐┌─┐┬─┐
        │  │ ││││└─┐ │ ├┬┘│ ││   │ │ │├┬┘
        └─┘└─┘┘└┘└─┘ ┴ ┴└─└─┘└─┘ ┴ └─┘┴└─   */
    /// @notice Constructor
    /// @dev Initialize `ERC721A` with `name_` and `symbol_`
    ///      Initialize ownership via `Solady.Ownable`
    constructor(string memory name_, string memory symbol_) ERC721Common(name_, symbol_) {}

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

        ComponentRenderRequest memory request = _onRendering(tokenId);
        _onRender(image, animation, attributes, request);
        _onRenderedInternal(image, animation, attributes);

        DynamicBufferLib.DynamicBuffer memory jsonBuffer = DynamicBufferLib.DynamicBuffer("{");
        jsonBuffer.append('"name":"', bytes(name()), '"');

        if (bytes(description()).length > 0) {
            jsonBuffer.append(',"description":"', bytes(description()), '"');
        }
        if (image.data.length > 0) {
            jsonBuffer.append(',"image":"data:image/svg+xml;base64,', bytes(image.data.encode()), '"');
        }
        if (animation.data.length > 0) {
            jsonBuffer.append(',"animation_url":"', animation.data, '"');
        }
        if (attributes.data.length > 0) {
            jsonBuffer.append(',"attributes":[', attributes.data, "]");
        }
        jsonBuffer.append("}");

        return string(abi.encodePacked("data:application/json;base64,", jsonBuffer.data.encode()));
    }

    /// @notice Component render function
    /// @dev Entry point for `ERC721Composable._renderComponents`
    ///      Has to be overridden by Component Implementation
    /// @param request ComponentRenderRequest Component render request
    /// @return response ComponentRenderResponse Component render response
    function renderExternally(ComponentRenderRequest memory request)
        external
        view
        existingToken(request.tokenId)
        returns (ComponentRenderResponse memory)
    {
        DynamicBufferLib.DynamicBuffer memory image;
        DynamicBufferLib.DynamicBuffer memory animation;
        DynamicBufferLib.DynamicBuffer memory attributes;

        _onRender(image, animation, attributes, request);

        return _onRenderedExternal(image, animation, attributes);
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

    /// @notice On rendered hook for internal calls
    /// @dev Executed after rendering internally
    ///      Has to be overridden with custom behaviour writing to buffers
    /// @param image DynamicBufferLib.DynamicBuffer Image buffer
    /// @param animation DynamicBufferLib.DynamicBuffer Animation buffer
    /// @param attributes DynamicBufferLib.DynamicBuffer Attributes buffer
    function _onRenderedInternal(
        DynamicBufferLib.DynamicBuffer memory image,
        DynamicBufferLib.DynamicBuffer memory animation,
        DynamicBufferLib.DynamicBuffer memory attributes
    ) internal view virtual;

    /// @notice On rendered hook for external calls
    /// @dev Executed after rendering externally
    ///      Has to be overridden with custom behaviour for serializing `ComponentRenderResponse`
    /// @param image DynamicBufferLib.DynamicBuffer Image buffer
    /// @param animation DynamicBufferLib.DynamicBuffer Animation buffer
    /// @param attributes DynamicBufferLib.DynamicBuffer Attributes buffer
    /// @return response ComponentRenderResponse Component render response
    function _onRenderedExternal(
        DynamicBufferLib.DynamicBuffer memory image,
        DynamicBufferLib.DynamicBuffer memory animation,
        DynamicBufferLib.DynamicBuffer memory attributes
    ) internal view virtual returns (ComponentRenderResponse memory response);
}
