// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "./mocks/ERC721ComponentMock.sol";

contract ERC721ComponentTest is Test {
    ERC721ComponentMock public component;

    function setUp() public {
        component = new ERC721ComponentMock();
    }

    function test_Mint() public virtual {
        uint256 amount = 100;

        // mint
        component.__mint(address(this), amount);

        for (uint256 i = 1; i < amount; ++i) {
            // expect minted
            assertEq(address(this), component.ownerOf(i));

            // expect seed correct
            uint256 configuration = component.__configurations(i);
            assertEq(configuration, uint64(uint256(keccak256(abi.encode(i, address(this))))));
        }
    }

    function test_Burn() public {
        uint256 amount = 100;

        // mint
        component.__mint(address(this), amount);

        for (uint256 i = 1; i < amount; ++i) {
            // burn
            component.__burn(i);

            // expect token configuration deleted
            uint256 configuration = component.__configurations(i);
            assertEq(configuration, 0);
        }
    }

    function test_TokenURI() public {
        // mint
        component.__mint(address(this), 1);

        // expect tokenURI not empty
        string memory tokenURI = component.tokenURI(1);
        assertTrue(bytes(tokenURI).length > 0);

        // expect revert on non-existing token
        vm.expectRevert(ERC721Common.InvalidTokenId.selector);
        component.tokenURI(2);
        console.log(tokenURI);
    }

    function test_RenderExternally() public {
        // mint
        component.__mint(address(this), 1);

        // expect tokenURI to not revert, hooks are not setup, so response should be empty
        ComponentRenderRequest memory request = ComponentRenderRequest(1, new bytes(0));
        ComponentRenderResponse memory response = component.renderExternally(request);
        assertEq(response.slotId, 0);
        assertEq(response.data.length, 0);

        // expect revert on non-existing token
        vm.expectRevert(ERC721Common.InvalidTokenId.selector);
        request = ComponentRenderRequest(2, new bytes(0));
        component.renderExternally(request);
    }
}
