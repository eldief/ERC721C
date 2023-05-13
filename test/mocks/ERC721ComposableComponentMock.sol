// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "../../src/ERC721ComposableComponent.sol";

// `__functions` are mock wrappers to internal functions
contract ERC721ComposableComponentMock is ERC721ComposableComponent {
    constructor() ERC721ComposableComponent("ERC721Composable", "ERC721C") {}

    // hooks
    function _beforeRender(uint256 itemId) internal view override returns (ComponentRenderRequest memory request) {}

    function _onRender(
        DynamicBufferLib.DynamicBuffer memory image,
        DynamicBufferLib.DynamicBuffer memory animation,
        DynamicBufferLib.DynamicBuffer memory attributes,
        ComponentRenderRequest memory request
    ) internal view override {}

    function _afterRender(
        DynamicBufferLib.DynamicBuffer memory image,
        DynamicBufferLib.DynamicBuffer memory animation,
        DynamicBufferLib.DynamicBuffer memory attributes
    ) internal view override {}

    function _beforeComponentRender(uint256 slotId, uint256 itemId, ComponentRenderRequest memory request)
        internal
        view
        override
    {}

    function _afterComponentRender(
        bool success,
        DynamicBufferLib.DynamicBuffer memory image,
        DynamicBufferLib.DynamicBuffer memory animation,
        DynamicBufferLib.DynamicBuffer memory attributes,
        ComponentRenderRequest memory request
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
