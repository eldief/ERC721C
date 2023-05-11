// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./IERC721Common.sol";

interface IERC721Composable is IERC721Common {
    /// @notice See `ERC721Composable.getComponent`
    function getComponent(uint256 tokenId, uint8 slotId) external view returns (uint256 componentId, uint256 itemId);

    /// @notice See `ERC721Composable.getComponentAddress`
    function getComponentAddress(uint256 componentId) external view returns (address componentAddress);

    /// @notice See `ERC721Composable.setComponent`
    function setComponent(uint256 tokenId, uint8 slotId, uint8 componentId, uint16 itemId) external;

    /// @notice See `ERC721Composable.setComponentAddress`
    function setComponentAddress(uint8 componentId, address componentAddress) external;
}
