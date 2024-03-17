// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24 <0.9.0;

import { Script, console2 } from "forge-std/Script.sol";

abstract contract BaseScript is Script {
  /// @dev Included to enable compilation of the script without a $MNEMONIC environment variable.
  string internal constant TEST_MNEMONIC = "test test test test test test test test test test test junk";

  /// @dev Needed for the deterministic deployments.
  bytes32 internal constant ZERO_SALT = bytes32(0);

  /// @dev The address of the transaction broadcaster.
  address internal broadcaster;

  /// @dev Used to derive the broadcaster's address if $PUBLIC_KEY is not defined.
  string internal mnemonic;

  /// @dev Initializes the transaction broadcaster like this:
  ///
  /// - If $PUBLIC_KEY is defined, use it.
  /// - Otherwise, derive the broadcaster address from $MNEMONIC.
  /// - If $MNEMONIC is not defined, default to a test mnemonic.
  ///
  /// The use case for $PUBLIC_KEY is to specify the broadcaster key and its address via the command line.
  constructor() {
    // address from = vm.envOr({ name: "PUBLIC_KEY", defaultValue: address(0) });
    address from = address(uint160(vm.envUint("PUBLIC_KEY")));

    if (from != address(0)) {
      broadcaster = from;
    } else {
      mnemonic = vm.envOr({ name: "MNEMONIC", defaultValue: TEST_MNEMONIC });
      (broadcaster, ) = deriveRememberKey({ mnemonic: mnemonic, index: 0 });
    }
  }

  modifier broadcast() {
    vm.startBroadcast(broadcaster);
    _;
    vm.stopBroadcast();
  }
}
