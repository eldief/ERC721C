// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "../../src/ERC721Composable.sol";

// `__functions` are mock wrappers to internal functions
contract ERC721ComposableMock is ERC721Composable {
    constructor(address owner_) ERC721Composable("ERC721Composable", "ERC721C", owner_) {}

    function __mint(address to, uint256 quantity) external payable {
        _mint(to, quantity);
    }

    function __configurations(uint256 tokenId) external view returns (uint256) {
        return _configurations[tokenId];
    }

    function __burn(uint256 tokenId) external {
        _burn(tokenId);
    }

    function __setExpansionSlot0(uint256 tokenId, uint8 expansionId, uint16 itemId) external {
        _setExpansion(tokenId, _EXPANSION_SLOT_0, expansionId, itemId);
    }

    function __getExpansionSlot0(uint256 tokenId) external view returns (uint256, uint256) {
        return _getExpansion(tokenId, _EXPANSION_SLOT_0);
    }

    function __setExpansionSlot1(uint256 tokenId, uint8 expansionId, uint16 itemId) external {
        _setExpansion(tokenId, _EXPANSION_SLOT_1, expansionId, itemId);
    }

    function __getExpansionSlot1(uint256 tokenId) external view returns (uint256, uint256) {
        return _getExpansion(tokenId, _EXPANSION_SLOT_1);
    }

    function __setExpansionSlot2(uint256 tokenId, uint8 expansionId, uint16 itemId) external {
        _setExpansion(tokenId, _EXPANSION_SLOT_2, expansionId, itemId);
    }

    function __getExpansionSlot2(uint256 tokenId) external view returns (uint256, uint256) {
        return _getExpansion(tokenId, _EXPANSION_SLOT_2);
    }

    function __setExpansionSlot3(uint256 tokenId, uint8 expansionId, uint16 itemId) external {
        _setExpansion(tokenId, _EXPANSION_SLOT_3, expansionId, itemId);
    }

    function __getExpansionSlot3(uint256 tokenId) external view returns (uint256, uint256) {
        return _getExpansion(tokenId, _EXPANSION_SLOT_3);
    }

    function __setExpansionSlot4(uint256 tokenId, uint8 expansionId, uint16 itemId) external {
        _setExpansion(tokenId, _EXPANSION_SLOT_4, expansionId, itemId);
    }

    function __getExpansionSlot4(uint256 tokenId) external view returns (uint256, uint256) {
        return _getExpansion(tokenId, _EXPANSION_SLOT_4);
    }

    function __setExpansionSlot5(uint256 tokenId, uint8 expansionId, uint16 itemId) external {
        _setExpansion(tokenId, _EXPANSION_SLOT_5, expansionId, itemId);
    }

    function __getExpansionSlot5(uint256 tokenId) external view returns (uint256, uint256) {
        return _getExpansion(tokenId, _EXPANSION_SLOT_5);
    }

    function __setExpansionSlot6(uint256 tokenId, uint8 expansionId, uint16 itemId) external {
        _setExpansion(tokenId, _EXPANSION_SLOT_6, expansionId, itemId);
    }

    function __getExpansionSlot6(uint256 tokenId) external view returns (uint256, uint256) {
        return _getExpansion(tokenId, _EXPANSION_SLOT_6);
    }

    function __setExpansionSlot7(uint256 tokenId, uint8 expansionId, uint16 itemId) external {
        _setExpansion(tokenId, _EXPANSION_SLOT_7, expansionId, itemId);
    }

    function __getExpansionSlot7(uint256 tokenId) external view returns (uint256, uint256) {
        return _getExpansion(tokenId, _EXPANSION_SLOT_7);
    }

    function __setExpansionAddress(uint8 expansionId, address expansionAddress) external {
        _setExpansionAddress(expansionId, expansionAddress);
    }

    function __getExpansionAddress(uint8 expansionId) external view returns (address) {
        return _getExpansionAddress(expansionId);
    }
}
