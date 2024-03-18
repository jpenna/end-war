// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24 <0.9.0;

// This implementation is based on this answer:
// https://stackoverflow.com/questions/47129173/how-to-convert-uint-to-string-in-solidity/71095692#71095692
// And had a good performance in benchmark tests:
// https://neznein9.medium.com/the-fastest-way-to-convert-uint256-to-string-in-solidity-b880cfa5f377
// I didn't check further though.

library IntToString {
  /// @dev Error when the value is greater than or equal to 1e32.
  error ValueMustBeLessThan1e32();

  function itoa32(uint256 x) private pure returns (uint256 y) {
    unchecked {
      if (x >= 1e32) {
        revert ValueMustBeLessThan1e32();
      }
      y = 0x3030303030303030303030303030303030303030303030303030303030303030;
      y += x % 10;
      x /= 10;
      y += x % 10 << 8;
      x /= 10;
      y += x % 10 << 16;
      x /= 10;
      y += x % 10 << 24;
      x /= 10;
      y += x % 10 << 32;
      x /= 10;
      y += x % 10 << 40;
      x /= 10;
      y += x % 10 << 48;
      x /= 10;
      y += x % 10 << 56;
      x /= 10;
      y += x % 10 << 64;
      x /= 10;
      y += x % 10 << 72;
      x /= 10;
      y += x % 10 << 80;
      x /= 10;
      y += x % 10 << 88;
      x /= 10;
      y += x % 10 << 96;
      x /= 10;
      y += x % 10 << 104;
      x /= 10;
      y += x % 10 << 112;
      x /= 10;
      y += x % 10 << 120;
      x /= 10;
      y += x % 10 << 128;
      x /= 10;
      y += x % 10 << 136;
      x /= 10;
      y += x % 10 << 144;
      x /= 10;
      y += x % 10 << 152;
      x /= 10;
      y += x % 10 << 160;
      x /= 10;
      y += x % 10 << 168;
      x /= 10;
      y += x % 10 << 176;
      x /= 10;
      y += x % 10 << 184;
      x /= 10;
      y += x % 10 << 192;
      x /= 10;
      y += x % 10 << 200;
      x /= 10;
      y += x % 10 << 208;
      x /= 10;
      y += x % 10 << 216;
      x /= 10;
      y += x % 10 << 224;
      x /= 10;
      y += x % 10 << 232;
      x /= 10;
      y += x % 10 << 240;
      x /= 10;
      y += x % 10 << 248;
    }
  }

  function itoa(uint256 x) internal pure returns (string memory s) {
    if (x == 0) return "0";

    unchecked {
      uint256 c1 = itoa32(x % 1e32);
      x /= 1e32;

      (x, c1, s) = getValues(x, c1, s);

      uint256 z = 0;
      if (c1 >> 128 == 0x30303030303030303030303030303030) {
        c1 <<= 128;
        z += 16;
      }
      if (c1 >> 192 == 0x3030303030303030) {
        c1 <<= 64;
        z += 8;
      }
      if (c1 >> 224 == 0x30303030) {
        c1 <<= 32;
        z += 4;
      }
      if (c1 >> 240 == 0x3030) {
        c1 <<= 16;
        z += 2;
      }
      if (c1 >> 248 == 0x30) {
        z += 1;
      }

      assembly {
        let l := mload(s)
        s := add(s, z)
        mstore(s, sub(l, z))
      }
    }
  }

  function getValues(uint256 x, uint256 c1, string memory s) private pure returns (uint256, uint256, string memory) {
    if (x == 0) s = string(abi.encode(c1));
    else {
      uint256 c2 = itoa32(x % 1e32);
      x /= 1e32;
      if (x == 0) {
        s = string(abi.encode(c2, c1));
        c1 = c2;
      } else {
        uint256 c3 = itoa32(x);
        s = string(abi.encode(c3, c2, c1));
        c1 = c3;
      }
    }

    return (x, c1, s);
  }
}
