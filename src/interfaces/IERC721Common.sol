// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@ERC721A/contracts/IERC721A.sol";
import "@solady/utils/Base64.sol";
import "@solady/utils/DynamicBufferLib.sol";

struct ComponentRenderRequest {
    uint256 itemId;
    uint256 slotId;
    bytes data;
}

interface IERC721Common is IERC721A {
    /// @notice See `ERC721Common.description`
    function description() external view returns (string memory);

    /// @notice See `ERC721Common.setDescription`
    function setDescription(string memory description_) external;
}
