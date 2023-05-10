// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./IERC721Common.sol";

interface IERC721Component is IERC721Common {
    function renderExternally(ComponentRenderRequest calldata request)
        external
        view
        returns (ComponentRenderResponse memory);
}
