// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "./mocks/ERC721ComposableMock.sol";

contract ERC721ComposableTest is Test {
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);
    event ComponentSet(uint256 indexed tokenId, uint256 indexed slotId, uint8 componentId, uint16 itemId);
    event MetadataUpdate(uint256 _tokenId);

    ERC721ComposableMock public composable;

    function setUp() public {
        composable = new ERC721ComposableMock();
    }

    function test_Mint() public {
        uint256 amount = 100;

        // mint
        composable.__mint(address(this), amount);

        for (uint256 i = 1; i < amount; ++i) {
            // expect minted
            assertEq(address(this), composable.ownerOf(i));

            // expect seed correct
            uint256 configuration = composable.__configurations(i);
            assertEq(configuration, uint64(uint256(keccak256(abi.encode(i, address(this))))));
        }
    }

    function test_Burn() public {
        uint256 amount = 100;

        // mint
        composable.__mint(address(this), amount);

        for (uint256 i = 1; i < amount; ++i) {
            // burn
            composable.__burn(i);

            // expect token configuration deleted
            uint256 configuration = composable.__configurations(i);
            assertEq(configuration, 0);
        }
    }

    function test_SetComponent() public {
        // mint
        composable.__mint(address(this), 1);

        // expect `MetadataUpdate` and `ComponentSet` emitted
        vm.expectEmit(true, false, false, true);
        emit MetadataUpdate(1);
        composable.setComponent(1, 0, 10, 10);
        vm.expectEmit(true, true, false, true);
        emit ComponentSet(1, 0, 10, 10);
        composable.setComponent(1, 0, 10, 10);

        vm.expectEmit(true, false, false, true);
        emit MetadataUpdate(1);
        composable.setComponent(1, 1, 20, 20);
        vm.expectEmit(true, true, false, true);
        emit ComponentSet(1, 1, 20, 20);
        composable.setComponent(1, 1, 20, 20);

        vm.expectEmit(true, false, false, true);
        emit MetadataUpdate(1);
        composable.setComponent(1, 2, 30, 30);
        vm.expectEmit(true, true, false, true);
        emit ComponentSet(1, 2, 30, 30);
        composable.setComponent(1, 2, 30, 30);

        vm.expectEmit(true, false, false, true);
        emit MetadataUpdate(1);
        composable.setComponent(1, 3, 40, 40);
        vm.expectEmit(true, true, false, true);
        emit ComponentSet(1, 3, 40, 40);
        composable.setComponent(1, 3, 40, 40);

        vm.expectEmit(true, false, false, true);
        emit MetadataUpdate(1);
        composable.setComponent(1, 4, 50, 50);
        vm.expectEmit(true, true, false, true);
        emit ComponentSet(1, 4, 50, 50);
        composable.setComponent(1, 4, 50, 50);

        vm.expectEmit(true, false, false, true);
        emit MetadataUpdate(1);
        composable.setComponent(1, 5, 60, 60);
        vm.expectEmit(true, true, false, true);
        emit ComponentSet(1, 5, 60, 60);
        composable.setComponent(1, 5, 60, 60);

        vm.expectEmit(true, false, false, true);
        emit MetadataUpdate(1);
        composable.setComponent(1, 6, 70, 70);
        vm.expectEmit(true, true, false, true);
        emit ComponentSet(1, 6, 70, 70);
        composable.setComponent(1, 6, 70, 70);

        vm.expectEmit(true, false, false, true);
        emit MetadataUpdate(1);
        composable.setComponent(1, 7, 80, 80);
        vm.expectEmit(true, true, false, true);
        emit ComponentSet(1, 7, 80, 80);
        composable.setComponent(1, 7, 80, 80);

        // expect values set correctly
        uint256 itemId;
        uint256 componentId;

        (componentId, itemId) = composable.getComponent(1, 0);
        assertEq(componentId, 10);
        assertEq(itemId, 10);

        (componentId, itemId) = composable.getComponent(1, 1);
        assertEq(componentId, 20);
        assertEq(itemId, 20);

        (componentId, itemId) = composable.getComponent(1, 2);
        assertEq(componentId, 30);
        assertEq(itemId, 30);

        (componentId, itemId) = composable.getComponent(1, 3);
        assertEq(componentId, 40);
        assertEq(itemId, 40);

        (componentId, itemId) = composable.getComponent(1, 4);
        assertEq(componentId, 50);
        assertEq(itemId, 50);

        (componentId, itemId) = composable.getComponent(1, 5);
        assertEq(componentId, 60);
        assertEq(itemId, 60);

        (componentId, itemId) = composable.getComponent(1, 6);
        assertEq(componentId, 70);
        assertEq(itemId, 70);

        (componentId, itemId) = composable.getComponent(1, 7);
        assertEq(componentId, 80);
        assertEq(itemId, 80);

        // expect revert on not-owned token
        vm.prank(address(0));
        vm.expectRevert(Ownable.Unauthorized.selector);
        composable.setComponent(1, 1, 20, 20);
    }

    function test_SetComponentAddress() public {
        // expect `BatchMetadataUpdate` emitted
        vm.prank(address(this));
        vm.expectEmit(false, false, false, true);
        emit BatchMetadataUpdate(0, UINT256_MAX);
        composable.setComponentAddress(1, address(69_420));

        // expect value set correctly
        address componentAddress = composable.getComponentAddress(1);
        assertEq(componentAddress, address(69_420));

        // expect revert not-address(this)
        vm.prank(address(0));
        vm.expectRevert(Ownable.Unauthorized.selector);
        composable.setComponentAddress(1, address(69_420));
    }

    function test_TokenURI() public {
        // mint
        composable.__mint(address(this), 1);

        // expect tokenURI not empty
        string memory tokenURI = composable.tokenURI(1);
        assertTrue(bytes(tokenURI).length > 0);

        // expect revert on non-existing token
        vm.expectRevert(ERC721Common.InvalidTokenId.selector);
        composable.tokenURI(2);
    }
}
