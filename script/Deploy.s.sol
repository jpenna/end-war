// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BaseScript } from "./Base.s.sol";
import { Upgrades } from "openzeppelin-foundry-upgrades/Upgrades.sol";
import { EndWarV1 } from "../src/EndWarV1.sol";

import { Script, console2 } from "forge-std/Script.sol";

contract Deploy is BaseScript {
  function run() public broadcast {
    Upgrades.deployTransparentProxy("EndWarV1.sol", broadcaster, abi.encodeCall(EndWarV1.initialize, (broadcaster)));
  }
}
