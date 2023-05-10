// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/// @title PackingLib
/// @author @eldief
/// @notice Helper to pack and unpack uint256
library PackingLib {
    /// @dev Internal function that packs bool
    /// @param packed uint256 Packed configuration
    /// @param offset uint8 Offset
    /// @param value bool Value to be set
    /// @return result uint256 Result packed configuration
    function packBool(uint256 packed, uint8 offset, bool value) internal pure returns (uint256 result) {
        assembly {
            switch value
            case 1 {
                // packed | (mask << offset)
                packed := or(packed, shl(offset, 0x01))
            }
            default {
                // packed & ~(mask << offset)
                packed := and(packed, not(shl(offset, 0x01)))
            }
            result := packed
        }
    }

    /// @dev Internal function that unpacks bool
    /// @param packed uint256 Packed configuration
    /// @param offset uint8 Offset
    /// @return value bool Unpacked value
    function unpackBool(uint256 packed, uint8 offset) internal pure returns (bool value) {
        assembly {
            // (packed >> offset) & mask > 0
            value := gt(and(shr(offset, packed), 0x01), 0)
        }
    }

    /// @dev Internal function that packs uint8
    /// @param packed uint256 Packed configuration
    /// @param offset uint8 Offset
    /// @param value uint16 Value to be set
    /// @return result uint256 Result packed configuration
    function packUInt8(uint256 packed, uint8 offset, uint8 value) internal pure returns (uint256 result) {
        assembly {
            // packed & ~(mask << offset)
            packed := and(packed, not(shl(offset, 0xFF)))
            // packed | (value << offset)
            result := or(packed, shl(offset, value))
        }
    }

    /// @dev Internal function that unpacks uint8
    /// @param packed uint256 Packed configuration
    /// @param offset uint8 Offset
    /// @return value uint256 Unpacked value
    function unpackUInt8(uint256 packed, uint8 offset) internal pure returns (uint256 value) {
        assembly {
            // (packed >> offset) & mask
            value := and(shr(offset, packed), 0xFF)
        }
    }

    /// @dev Internal function that packs uint16
    /// @param packed uint256 Packed configuration
    /// @param offset uint8 Offset
    /// @param value uint16 Value to be set
    /// @return result uint256 Result packed configuration
    function packUInt16(uint256 packed, uint8 offset, uint16 value) internal pure returns (uint256 result) {
        assembly {
            // packed & ~(mask << offset)
            packed := and(packed, not(shl(offset, 0xFFFF)))
            // packed | (value << offset)
            result := or(packed, shl(offset, value))
        }
    }

    /// @dev Internal function that unpacks uint16
    /// @param packed uint256 Packed configuration
    /// @param offset uint8 Offset
    /// @return value uint256 Unpacked value
    function unpackUInt16(uint256 packed, uint8 offset) internal pure returns (uint256 value) {
        assembly {
            // (packed >> offset) & mask
            value := and(shr(offset, packed), 0xFFFF)
        }
    }

    /// @dev Internal function that packs uint32
    /// @param packed uint256 Packed configuration
    /// @param offset uint8 Offset
    /// @param value uint32 Value to be set
    /// @return result uint256 Result packed configuration
    function packUInt32(uint256 packed, uint8 offset, uint32 value) internal pure returns (uint256 result) {
        assembly {
            // packed & ~(mask << offset)
            packed := and(packed, not(shl(offset, 0xFFFFFFFF)))
            // packed | (value << offset)
            result := or(packed, shl(offset, value))
        }
    }

    /// @dev Internal function that unpacks uint32
    /// @param packed uint256 Packed configuration
    /// @param offset uint8 Offset
    /// @return value uint256 Unpacked value
    function unpackUInt32(uint256 packed, uint8 offset) internal pure returns (uint256 value) {
        assembly {
            // (packed >> offset) & mask
            value := and(shr(offset, packed), 0xFFFFFFFF)
        }
    }

    /// @dev Internal function that packs uint64
    /// @param packed uint256 Packed configuration
    /// @param offset uint8 Offset
    /// @param value uint64 Value to be set
    /// @return result uint256 Result packed configuration
    function packUInt64(uint256 packed, uint8 offset, uint64 value) internal pure returns (uint256 result) {
        assembly {
            // packed & ~(mask << offset)
            packed := and(packed, not(shl(offset, 0xFFFFFFFFFFFFFFFF)))
            // packed | (value << offset)
            result := or(packed, shl(offset, value))
        }
    }

    /// @dev Internal function that unpacks uint64
    /// @param packed uint256 Packed configuration
    /// @param offset uint8 Offset
    /// @return value uint256 Unpacked value
    function unpackUInt64(uint256 packed, uint8 offset) internal pure returns (uint256 value) {
        assembly {
            // (packed >> offset) & mask
            value := and(shr(offset, packed), 0xFFFFFFFFFFFFFFFF)
        }
    }

    /// @dev Internal function that packs address
    /// @param packed uint256 Packed configuration
    /// @param offset uint8 Offset
    /// @param value address Value to be set
    /// @return result uint256 Result packed configuration
    function packAddress(uint256 packed, uint8 offset, address value) internal pure returns (uint256 result) {
        assembly {
            // packed & ~(mask << offset)
            packed := and(packed, not(shl(offset, 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF)))
            // packed | (value << offset)
            result := or(packed, shl(offset, value))
        }
    }

    /// @dev Internal function that unpacks address
    /// @param packed uint256 Packed configuration
    /// @param offset uint8 Offset
    /// @return value address Unpacked value
    function unpackAddress(uint256 packed, uint8 offset) internal pure returns (address value) {
        assembly {
            // (packed >> offset) & mask
            value := and(shr(offset, packed), 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF)
        }
    }
}
