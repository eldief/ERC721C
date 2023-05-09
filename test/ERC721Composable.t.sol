// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "./mocks/ERC721ComposableMock.sol";

contract ERC721ComposableTest is Test {
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);
    event ExpansionSet(uint256 indexed tokenId, uint256 indexed slotId, uint8 expansionId, uint16 itemId);
    event MetadataUpdate(uint256 _tokenId);

    address public owner;
    ERC721ComposableMock public composable;

    function setUp() public {
        owner = msg.sender;
        composable = new ERC721ComposableMock(msg.sender);
    }

    function test_Mint() public {
        uint256 amount = 100;

        // mint
        composable.__mint(owner, amount);

        for (uint256 i = 1; i < amount; ++i) {
            // expect minted
            assertEq(owner, composable.ownerOf(i));

            // expect seed correct
            uint256 configuration = composable.__configurations(i);
            assertEq(configuration, uint64(uint256(keccak256(abi.encode(i, address(this))))));
        }
    }

    function test_Burn() public {
        uint256 amount = 100;

        // mint
        composable.__mint(owner, amount);

        for (uint256 i = 1; i < amount; ++i) {
            // burn
            composable.__burn(i);

            // expect token configuration deleted
            uint256 configuration = composable.__configurations(i);
            assertEq(configuration, 0);
        }
    }

    function test_SetExpansionSlot() public {
        // mint
        composable.__mint(address(this), 1);

        // expect `MetadataUpdate` and `ExpansionSet` emitted
        vm.expectEmit(true, false, false, true);
        emit MetadataUpdate(1);
        composable.__setExpansionSlot0(1, 10, 10);
        vm.expectEmit(true, true, false, true);
        emit ExpansionSet(1, 0, 10, 10);
        composable.__setExpansionSlot0(1, 10, 10);

        vm.expectEmit(true, false, false, true);
        emit MetadataUpdate(1);
        composable.__setExpansionSlot1(1, 20, 20);
        vm.expectEmit(true, true, false, true);
        emit ExpansionSet(1, 1, 20, 20);
        composable.__setExpansionSlot1(1, 20, 20);

        vm.expectEmit(true, false, false, true);
        emit MetadataUpdate(1);
        composable.__setExpansionSlot2(1, 30, 30);
        vm.expectEmit(true, true, false, true);
        emit ExpansionSet(1, 2, 30, 30);
        composable.__setExpansionSlot2(1, 30, 30);

        vm.expectEmit(true, false, false, true);
        emit MetadataUpdate(1);
        composable.__setExpansionSlot3(1, 40, 40);
        vm.expectEmit(true, true, false, true);
        emit ExpansionSet(1, 3, 40, 40);
        composable.__setExpansionSlot3(1, 40, 40);

        vm.expectEmit(true, false, false, true);
        emit MetadataUpdate(1);
        composable.__setExpansionSlot4(1, 50, 50);
        vm.expectEmit(true, true, false, true);
        emit ExpansionSet(1, 4, 50, 50);
        composable.__setExpansionSlot4(1, 50, 50);

        vm.expectEmit(true, false, false, true);
        emit MetadataUpdate(1);
        composable.__setExpansionSlot5(1, 60, 60);
        vm.expectEmit(true, true, false, true);
        emit ExpansionSet(1, 5, 60, 60);
        composable.__setExpansionSlot5(1, 60, 60);

        vm.expectEmit(true, false, false, true);
        emit MetadataUpdate(1);
        composable.__setExpansionSlot6(1, 70, 70);
        vm.expectEmit(true, true, false, true);
        emit ExpansionSet(1, 6, 70, 70);
        composable.__setExpansionSlot6(1, 70, 70);

        vm.expectEmit(true, false, false, true);
        emit MetadataUpdate(1);
        composable.__setExpansionSlot7(1, 80, 80);
        vm.expectEmit(true, true, false, true);
        emit ExpansionSet(1, 7, 80, 80);
        composable.__setExpansionSlot7(1, 80, 80);

        // expect values set correctly
        uint256 itemId;
        uint256 expansionId;

        (expansionId, itemId) = composable.__getExpansionSlot0(1);
        assertEq(expansionId, 10);
        assertEq(itemId, 10);

        (expansionId, itemId) = composable.__getExpansionSlot1(1);
        assertEq(expansionId, 20);
        assertEq(itemId, 20);

        (expansionId, itemId) = composable.__getExpansionSlot2(1);
        assertEq(expansionId, 30);
        assertEq(itemId, 30);

        (expansionId, itemId) = composable.__getExpansionSlot3(1);
        assertEq(expansionId, 40);
        assertEq(itemId, 40);

        (expansionId, itemId) = composable.__getExpansionSlot4(1);
        assertEq(expansionId, 50);
        assertEq(itemId, 50);

        (expansionId, itemId) = composable.__getExpansionSlot5(1);
        assertEq(expansionId, 60);
        assertEq(itemId, 60);

        (expansionId, itemId) = composable.__getExpansionSlot6(1);
        assertEq(expansionId, 70);
        assertEq(itemId, 70);

        (expansionId, itemId) = composable.__getExpansionSlot7(1);
        assertEq(expansionId, 80);
        assertEq(itemId, 80);
    }

    function test_SetExpansionAddress() public {
        // expect `BatchMetadataUpdate` emitted
        vm.prank(owner);
        vm.expectEmit(false, false, false, true);
        emit BatchMetadataUpdate(0, UINT256_MAX);
        composable.__setExpansionAddress(1, address(69_420));

        // expect value set correctly
        address expansionAddress = composable.__getExpansionAddress(1);
        assertEq(expansionAddress, address(69_420));
    }
}
