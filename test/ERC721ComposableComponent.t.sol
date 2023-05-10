// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "./mocks/ERC721ComposableComponentMock.sol";

contract ERC721ComposableComponentTest is Test {
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);
    event ComponentSet(uint256 indexed tokenId, uint256 indexed slotId, uint8 componentId, uint16 itemId);
    event MetadataUpdate(uint256 _tokenId);

    ERC721ComposableComponentMock public composableComponent;

    function setUp() public {
        composableComponent = new ERC721ComposableComponentMock();
    }

    function test_Mint() public {
        uint256 amount = 100;

        // mint
        composableComponent.__mint(address(this), amount);

        for (uint256 i = 1; i < amount; ++i) {
            // expect minted
            assertEq(address(this), composableComponent.ownerOf(i));

            // expect seed correct
            uint256 configuration = composableComponent.__configurations(i);
            assertEq(configuration, uint64(uint256(keccak256(abi.encode(i, address(this))))));
        }
    }

    function test_Burn() public {
        uint256 amount = 100;

        // mint
        composableComponent.__mint(address(this), amount);

        for (uint256 i = 1; i < amount; ++i) {
            // burn
            composableComponent.__burn(i);

            // expect token configuration deleted
            uint256 configuration = composableComponent.__configurations(i);
            assertEq(configuration, 0);
        }
    }

    function test_SetComponentSlot() public {
        // mint
        composableComponent.__mint(address(this), 1);

        // expect `MetadataUpdate` and `ComponentSet` emitted
        vm.expectEmit(true, false, false, true);
        emit MetadataUpdate(1);
        composableComponent.__setComponentSlot0(1, 10, 10);
        vm.expectEmit(true, true, false, true);
        emit ComponentSet(1, 0, 10, 10);
        composableComponent.__setComponentSlot0(1, 10, 10);

        vm.expectEmit(true, false, false, true);
        emit MetadataUpdate(1);
        composableComponent.__setComponentSlot1(1, 20, 20);
        vm.expectEmit(true, true, false, true);
        emit ComponentSet(1, 1, 20, 20);
        composableComponent.__setComponentSlot1(1, 20, 20);

        vm.expectEmit(true, false, false, true);
        emit MetadataUpdate(1);
        composableComponent.__setComponentSlot2(1, 30, 30);
        vm.expectEmit(true, true, false, true);
        emit ComponentSet(1, 2, 30, 30);
        composableComponent.__setComponentSlot2(1, 30, 30);

        vm.expectEmit(true, false, false, true);
        emit MetadataUpdate(1);
        composableComponent.__setComponentSlot3(1, 40, 40);
        vm.expectEmit(true, true, false, true);
        emit ComponentSet(1, 3, 40, 40);
        composableComponent.__setComponentSlot3(1, 40, 40);

        vm.expectEmit(true, false, false, true);
        emit MetadataUpdate(1);
        composableComponent.__setComponentSlot4(1, 50, 50);
        vm.expectEmit(true, true, false, true);
        emit ComponentSet(1, 4, 50, 50);
        composableComponent.__setComponentSlot4(1, 50, 50);

        vm.expectEmit(true, false, false, true);
        emit MetadataUpdate(1);
        composableComponent.__setComponentSlot5(1, 60, 60);
        vm.expectEmit(true, true, false, true);
        emit ComponentSet(1, 5, 60, 60);
        composableComponent.__setComponentSlot5(1, 60, 60);

        vm.expectEmit(true, false, false, true);
        emit MetadataUpdate(1);
        composableComponent.__setComponentSlot6(1, 70, 70);
        vm.expectEmit(true, true, false, true);
        emit ComponentSet(1, 6, 70, 70);
        composableComponent.__setComponentSlot6(1, 70, 70);

        vm.expectEmit(true, false, false, true);
        emit MetadataUpdate(1);
        composableComponent.__setComponentSlot7(1, 80, 80);
        vm.expectEmit(true, true, false, true);
        emit ComponentSet(1, 7, 80, 80);
        composableComponent.__setComponentSlot7(1, 80, 80);

        // expect values set correctly
        uint256 itemId;
        uint256 componentId;

        (componentId, itemId) = composableComponent.__getComponentSlot0(1);
        assertEq(componentId, 10);
        assertEq(itemId, 10);

        (componentId, itemId) = composableComponent.__getComponentSlot1(1);
        assertEq(componentId, 20);
        assertEq(itemId, 20);

        (componentId, itemId) = composableComponent.__getComponentSlot2(1);
        assertEq(componentId, 30);
        assertEq(itemId, 30);

        (componentId, itemId) = composableComponent.__getComponentSlot3(1);
        assertEq(componentId, 40);
        assertEq(itemId, 40);

        (componentId, itemId) = composableComponent.__getComponentSlot4(1);
        assertEq(componentId, 50);
        assertEq(itemId, 50);

        (componentId, itemId) = composableComponent.__getComponentSlot5(1);
        assertEq(componentId, 60);
        assertEq(itemId, 60);

        (componentId, itemId) = composableComponent.__getComponentSlot6(1);
        assertEq(componentId, 70);
        assertEq(itemId, 70);

        (componentId, itemId) = composableComponent.__getComponentSlot7(1);
        assertEq(componentId, 80);
        assertEq(itemId, 80);

        // expect revert on not-owned token
        vm.prank(address(0));
        vm.expectRevert(Ownable.Unauthorized.selector);
        composableComponent.__setComponentSlot1(1, 20, 20);
    }

    function test_SetComponentAddress() public {
        // expect `BatchMetadataUpdate` emitted
        vm.prank(address(this));
        vm.expectEmit(false, false, false, true);
        emit BatchMetadataUpdate(0, UINT256_MAX);
        composableComponent.__setComponentAddress(1, address(69_420));

        // expect value set correctly
        address componentAddress = composableComponent.__getComponentAddress(1);
        assertEq(componentAddress, address(69_420));

        // expect revert not-address(this)
        vm.prank(address(0));
        vm.expectRevert(Ownable.Unauthorized.selector);
        composableComponent.__setComponentAddress(1, address(69_420));
    }

    function test_TokenURI() public {
        // mint
        composableComponent.__mint(address(this), 1);

        // expect tokenURI not empty
        string memory tokenURI = composableComponent.tokenURI(1);
        assertTrue(bytes(tokenURI).length > 0);

        // expect revert on non-existing token
        vm.expectRevert(ERC721Common.InvalidTokenId.selector);
        composableComponent.tokenURI(2);
    }

    function test_RenderExternally() public {
        // mint
        composableComponent.__mint(address(this), 1);

        // expect tokenURI to not revert, hooks are not setup, so response should be empty
        ComponentRenderRequest memory request = ComponentRenderRequest(1, new bytes(0));
        ComponentRenderResponse memory response = composableComponent.renderExternally(request);
        assertEq(response.slotId, 0);
        assertEq(response.data.length, 0);

        // expect revert on non-existing token
        vm.expectRevert(ERC721Common.InvalidTokenId.selector);
        request = ComponentRenderRequest(2, new bytes(0));
        composableComponent.renderExternally(request);
    }
}
