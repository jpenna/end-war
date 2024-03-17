// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.24;

import { Test } from "forge-std/Test.sol";
import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { Upgrades } from "openzeppelin-foundry-upgrades/Upgrades.sol";
import { Options } from "openzeppelin-foundry-upgrades/Options.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import { EndWarV1, POWER_PER_PERSON, MIN_WAR_FUNDS } from "../src/EndWarV1.sol";
import { World } from "../src/libs/World.sol";
import { GameErrors } from "../src/libs/GameErrors.sol";
import { GameEvents } from "../src/libs/GameEvents.sol";

address constant ownerAddress = address(0x1);

contract EndWarTest is Test {
  EndWarV1 internal endWar;

  function setUp() public virtual {
    address proxy = Upgrades.deployTransparentProxy(
      "EndWarV1.sol",
      ownerAddress,
      abi.encodeCall(EndWarV1.initialize, (ownerAddress))
    );
    endWar = EndWarV1(proxy);
  }

  function test_intialTerritories() external view {
    assertEq(endWar.totalPopulation(), 920_000);
    assertEq(endWar.minWarFunds(), 500_000 gwei);

    World.Territory memory a = endWar.getTerritory("A");
    World.Territory memory b = endWar.getTerritory("B");
    World.Territory memory c = endWar.getTerritory("C");
    World.Territory memory d = endWar.getTerritory("D");
    World.Territory memory e = endWar.getTerritory("E");

    assertEq(a.name, "A");
    assertEq(b.name, "B");
    assertEq(c.name, "C");
    assertEq(d.name, "D");
    assertEq(e.name, "E");

    assertEq(a.population, 100_000);
    assertEq(b.population, 90_000);
    assertEq(c.population, 400_000);
    assertEq(d.population, 130_000);
    assertEq(e.population, 200_000);

    assertEq(a.power, 100_000 * POWER_PER_PERSON);
    assertEq(b.power, 90_000 * POWER_PER_PERSON);
    assertEq(c.power, 400_000 * POWER_PER_PERSON);
    assertEq(d.power, 130_000 * POWER_PER_PERSON);
    assertEq(e.power, 200_000 * POWER_PER_PERSON);

    // 2 neighbors
    string[] memory neighbors = new string[](2);
    neighbors[0] = "B";
    neighbors[1] = "C";
    assertEq(a.neighbors, neighbors);
    neighbors = new string[](2);
    neighbors[0] = "C";
    neighbors[1] = "D";
    assertEq(e.neighbors, neighbors);

    // 3 neighbors
    neighbors = new string[](3);
    neighbors[0] = "A";
    neighbors[1] = "C";
    neighbors[2] = "D";
    assertEq(b.neighbors, neighbors);
    neighbors = new string[](3);
    neighbors[0] = "B";
    neighbors[1] = "C";
    neighbors[2] = "E";
    assertEq(d.neighbors, neighbors);

    // 4 neighbors
    neighbors = new string[](4);
    neighbors[0] = "A";
    neighbors[1] = "B";
    neighbors[2] = "D";
    neighbors[3] = "E";
    assertEq(c.neighbors, neighbors);
  }

  function test_setMinWarFunds() external {
    vm.prank(ownerAddress);
    endWar.setMinWarFunds(10 ether);
    assertEq(endWar.minWarFunds(), 10 ether);
  }

  function test_setMinWarFunds_onlyOwner() external {
    address sender = address(0x1234);
    vm.prank(sender);
    vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, sender));
    endWar.setMinWarFunds(10 ether);
    assertEq(endWar.minWarFunds(), 500_000 gwei);
  }

  function test_invest_minValue() external payable {
    vm.prank(ownerAddress);
    vm.expectRevert(abi.encodeWithSelector(GameErrors.MinWarFundsTooLow.selector, MIN_WAR_FUNDS));
    endWar.setMinWarFunds(5 gwei);
    assertEq(endWar.minWarFunds(), 500_000 gwei);
  }

  function test_invest() external payable {
    endWar.invest{ value: 1 ether }("A");
    World.Territory memory a = endWar.getTerritory("A");
    assertEq(a.power, uint128(a.population) * POWER_PER_PERSON + 1 ether);
  }

  function test_invest_ifNoValue_reverts() external payable {
    vm.expectRevert(GameErrors.MissingInvestmentValue.selector);

    endWar.invest("A");

    World.Territory memory a = endWar.getTerritory("A");
    assertEq(a.power, uint128(a.population) * POWER_PER_PERSON);
  }

  function test_triggerWar() external payable {
    address sender = address(0x1234);
    vm.deal(sender, 10 ether);
    vm.prank(sender);
    // TODO vm.hoax(sender);

    uint256 warFunds = 1 ether;

    string memory attacker = "A";
    string memory target = "B";

    vm.expectEmit(false, false, false, true);
    emit GameEvents.TerritoryInvested(attacker, sender, warFunds);
    vm.expectEmit(false, false, false, true);
    emit GameEvents.TerritoryAttacked(sender, attacker, target);

    endWar.triggerWar{ value: warFunds }(attacker, target);

    World.Territory memory a = endWar.getTerritory("A");
    World.Territory memory b = endWar.getTerritory("B");

    assertEq(a.population, 90_000);
    assertEq(b.population, 71_987);
  }

  function test_triggerWar_destroysTerritory() external payable {
    address sender = address(0x1234);
    vm.deal(sender, 100_000 ether);
    vm.prank(sender);
    // TODO vm.hoax(sender);

    uint256 warFunds = 100_000 ether;

    string memory attacker = "A";
    string memory target = "B";

    vm.expectEmit(false, false, false, true);
    emit GameEvents.TerritoryDestroyed(target, sender);

    endWar.triggerWar{ value: warFunds }(attacker, target);

    World.Territory memory a = endWar.getTerritory("A");
    World.Territory memory b = endWar.getTerritory("B");

    assertEq(a.population, 90_000);
    assertEq(b.population, 0);
  }

  function test_triggerWar_ifMissingValue_reverts() external payable {
    vm.expectRevert(abi.encodeWithSelector(GameErrors.NotEnoughFundsForWar.selector, 0, endWar.minWarFunds()));

    string memory attacker = "A";
    string memory target = "B";
    endWar.triggerWar(attacker, target);
  }

  function test_triggerWar_ifAttackerNotFound_reverts() external payable {
    string memory attacker = "NOT_FOUND";
    string memory target = "B";

    vm.expectRevert(abi.encodeWithSelector(GameErrors.TerritoryNotFound.selector, attacker));
    endWar.triggerWar{ value: 1 ether }(attacker, target);
  }

  function test_triggerWar_ifTargetNotFound_reverts() external payable {
    string memory attacker = "A";
    string memory target = "NOT_FOUND";

    vm.expectRevert(abi.encodeWithSelector(GameErrors.TerritoryNotFound.selector, target));
    endWar.triggerWar{ value: 1 ether }(attacker, target);
  }
}
