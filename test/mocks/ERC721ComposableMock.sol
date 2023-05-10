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

    function __setComponentSlot0(uint256 tokenId, uint8 componentId, uint16 itemId) external {
        _setComponent(tokenId, _COMPONENT_SLOT_0, componentId, itemId);
    }

    function __getComponentSlot0(uint256 tokenId) external view returns (uint256, uint256) {
        return _getComponent(tokenId, _COMPONENT_SLOT_0);
    }

    function __setComponentSlot1(uint256 tokenId, uint8 componentId, uint16 itemId) external {
        _setComponent(tokenId, _COMPONENT_SLOT_1, componentId, itemId);
    }

    function __getComponentSlot1(uint256 tokenId) external view returns (uint256, uint256) {
        return _getComponent(tokenId, _COMPONENT_SLOT_1);
    }

    function __setComponentSlot2(uint256 tokenId, uint8 componentId, uint16 itemId) external {
        _setComponent(tokenId, _COMPONENT_SLOT_2, componentId, itemId);
    }

    function __getComponentSlot2(uint256 tokenId) external view returns (uint256, uint256) {
        return _getComponent(tokenId, _COMPONENT_SLOT_2);
    }

    function __setComponentSlot3(uint256 tokenId, uint8 componentId, uint16 itemId) external {
        _setComponent(tokenId, _COMPONENT_SLOT_3, componentId, itemId);
    }

    function __getComponentSlot3(uint256 tokenId) external view returns (uint256, uint256) {
        return _getComponent(tokenId, _COMPONENT_SLOT_3);
    }

    function __setComponentSlot4(uint256 tokenId, uint8 componentId, uint16 itemId) external {
        _setComponent(tokenId, _COMPONENT_SLOT_4, componentId, itemId);
    }

    function __getComponentSlot4(uint256 tokenId) external view returns (uint256, uint256) {
        return _getComponent(tokenId, _COMPONENT_SLOT_4);
    }

    function __setComponentSlot5(uint256 tokenId, uint8 componentId, uint16 itemId) external {
        _setComponent(tokenId, _COMPONENT_SLOT_5, componentId, itemId);
    }

    function __getComponentSlot5(uint256 tokenId) external view returns (uint256, uint256) {
        return _getComponent(tokenId, _COMPONENT_SLOT_5);
    }

    function __setComponentSlot6(uint256 tokenId, uint8 componentId, uint16 itemId) external {
        _setComponent(tokenId, _COMPONENT_SLOT_6, componentId, itemId);
    }

    function __getComponentSlot6(uint256 tokenId) external view returns (uint256, uint256) {
        return _getComponent(tokenId, _COMPONENT_SLOT_6);
    }

    function __setComponentSlot7(uint256 tokenId, uint8 componentId, uint16 itemId) external {
        _setComponent(tokenId, _COMPONENT_SLOT_7, componentId, itemId);
    }

    function __getComponentSlot7(uint256 tokenId) external view returns (uint256, uint256) {
        return _getComponent(tokenId, _COMPONENT_SLOT_7);
    }

    function __setComponentAddress(uint8 componentId, address componentAddress) external {
        _setComponentAddress(componentId, componentAddress);
    }

    function __getComponentAddress(uint8 componentId) external view returns (address) {
        return _getComponentAddress(componentId);
    }
}
