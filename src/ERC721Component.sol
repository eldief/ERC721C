// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./interfaces/IERC721Component.sol";
import "./common/ERC721Common.sol";

/// @title ERC721Component
/// @author @eldief
/// @notice Contract defining base functionalities for ERC721 Component
/// @dev Abstract contract providing internal methods to expose via external aliases
///      `Contract Configuration` and `Component Registry` expose custom data, customizable by implementations
///      Custom `Token Configuration` layout:
///      - [0..63]    `Seed`
///      - [64..255]  `Custom data`
abstract contract ERC721Component is IERC721Component, ERC721Common {
    using Base64 for bytes;
    using LibString for uint256;
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
        DynamicBufferLib.DynamicBuffer memory buffer1;
        DynamicBufferLib.DynamicBuffer memory buffer2;

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
    /// @notice On  rendering hook
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
}
