// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "../libraries/PackingLib.sol";
import "@ERC721A/contracts/IERC721A.sol";
import "@solady/utils/Base64.sol";
import "@solady/utils/SSTORE2.sol";
import "@solady/utils/LibString.sol";
import "@solady/utils/DynamicBufferLib.sol";

struct ComponentRenderRequest {
    uint256 itemId;
    bytes data;
}

struct ComponentRenderResponse {
    uint256 slotId;
    bytes data;
}

interface IERC721Common is IERC721A {}
