// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "../../src/ERC721Composable.sol";

// `__functions` are mock wrappers to internal functions
contract ERC721ComposableMock is ERC721Composable {
    constructor() ERC721Composable("ERC721Composable", "ERC721C") {}

    // hooks
    function _onRendering(uint256 itemId) internal view override returns (ComponentRenderRequest memory request) {}

    function _onRender(
        DynamicBufferLib.DynamicBuffer memory buffer1,
        DynamicBufferLib.DynamicBuffer memory buffer2,
        ComponentRenderRequest memory request
    ) internal view override {}

    function _onRendered(DynamicBufferLib.DynamicBuffer memory buffer1, DynamicBufferLib.DynamicBuffer memory buffer2)
        internal
        view
        override
    {}

    function _onComponentRendering(uint256 itemId)
        internal
        view
        override
        returns (ComponentRenderRequest memory request)
    {}

    function _onComponentRendered(
        DynamicBufferLib.DynamicBuffer memory buffer1,
        DynamicBufferLib.DynamicBuffer memory buffer2,
        ComponentRenderResponse memory response
    ) internal view override {}

    // mocks
    function __mint(address to, uint256 quantity) external payable {
        _mint(to, quantity);
    }

    function __configurations(uint256 tokenId) external view returns (uint256) {
        return _configurations[tokenId];
    }

    function __burn(uint256 tokenId) external {
        _burn(tokenId);
    }
}
