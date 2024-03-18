// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BaseScript } from "./Base.s.sol";
import { Upgrades } from "openzeppelin-foundry-upgrades/Upgrades.sol";
import { EndWarV1 } from "../src/EndWarV1.sol";

contract Deploy is BaseScript {
  bytes private data = abi.encodeCall(EndWarV1.initialize, (broadcaster));

  function run() public broadcast {
    Upgrades.deployTransparentProxy("EndWarV1.sol", broadcaster, data);
  }
}

contract Upgrade is BaseScript {
  address private proxy = address(0x3eA7Fd6A0B1023b9632eDEA7377DDdc37bd86C8a);
  string private contractName = "EndWarV2.sol";
  bytes private data = "";

  function run() public broadcast {
    Upgrades.upgradeProxy(proxy, contractName, data);
  }
}
