// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24 <0.9.0;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import { World } from "./libs/World.sol";
import { GameErrors } from "./libs/GameErrors.sol";
import { GameEvents } from "./libs/GameEvents.sol";
import { IterableTerritoryMapping } from "./libs/IterableTerritoryMapping.sol";

uint128 constant POWER_PER_PERSON = 1000 gwei;
uint128 constant MIN_WAR_FUNDS = 5000 gwei;

/**
 * @title EndWarV1
 * @dev The main contract of the game.
 */
contract EndWarV1 is Initializable, OwnableUpgradeable, GameErrors, GameEvents {
  using IterableTerritoryMapping for IterableTerritoryMapping.Map;
  using World for World.Territory;

  IterableTerritoryMapping.Map private territories;
  uint256 public totalPopulation;
  uint256 public minWarFunds;

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
    _disableInitializers();
  }

  function initialize(address initialOwner) public initializer {
    __Ownable_init(initialOwner);

    initializeTerritories();
    minWarFunds = 500_000 gwei;
  }

  /**
   * @dev Initialize the territories of the game.
   * @dev This function is called only once during the contract deployment.
   */
  function initializeTerritories() private {
    string[] memory neighborsPlaceholder = new string[](0);
    World.Territory storage a = newTerritory("A", 100_000, neighborsPlaceholder);
    World.Territory storage b = newTerritory("B", 90_000, neighborsPlaceholder);
    World.Territory storage c = newTerritory("C", 400_000, neighborsPlaceholder);
    World.Territory storage d = newTerritory("D", 130_000, neighborsPlaceholder);
    World.Territory storage e = newTerritory("E", 200_000, neighborsPlaceholder);

    a.addNeighbor(b);
    a.addNeighbor(c);
    b.addNeighbor(c);
    b.addNeighbor(d);
    c.addNeighbor(d);
    c.addNeighbor(e);
    d.addNeighbor(e);
  }

  /**
   * @dev Create a new territory and add it to the territories mapping.
   */
  function newTerritory(
    string memory name,
    uint64 population,
    string[] memory neighbors
  ) private returns (World.Territory storage territory) {
    territory = territories.get(name);

    territory.name = name;
    territory.population = population;
    territory.power = uint128(population) * POWER_PER_PERSON;

    for (uint256 i = 0; i < neighbors.length; i++) {
      territory.addNeighbor(territories.get(neighbors[i]));
    }

    territories.set(name, territory);

    totalPopulation += population;
  }

  /**
   * @dev Set the minimum war funds required to trigger a war.
   */
  function setMinWarFunds(uint256 newMinWarFunds) external onlyOwner {
    if (newMinWarFunds < MIN_WAR_FUNDS) {
      revert MinWarFundsTooLow(MIN_WAR_FUNDS);
    }
    minWarFunds = newMinWarFunds;
  }

  /**
   * Invest in a territory.
   * The investment is converted into territory's power and used to attack others.
   */
  function invest(string calldata territoryName) external payable {
    World.Territory storage territory = territories.get(territoryName);
    if (territory.population == 0) {
      revert TerritoryNotFound(territoryName);
    }
    if (msg.value == 0) {
      revert MissingInvestmentValue();
    }

    territory.invest(msg.value);
  }

  /**
   * Trigger a war between two territories.
   * The attacker must invest a minimum amount of funds to trigger a war.
   * The attacker must be a neighbor of the target territory, or invest twice the minimum amount of funds.
   * If the attacker is not a neighbor, the minimum amount of funds is used for logistics and other difficulties and
   * removed before investment.
   * The attacker's investment is used to increase the power of the attacker territory.
   * The target's population is reduced according to the attacker's power and the attackers population is also reduced
   * to when going to war.
   */
  function triggerWar(string memory attackerName, string memory targetName) external payable {
    uint256 warFunds = msg.value;
    if (warFunds < minWarFunds) {
      revert NotEnoughFundsForWar(warFunds, minWarFunds);
    }

    World.Territory storage attacker = territories.get(attackerName);
    if (attacker.population == 0) {
      revert TerritoryNotFound(attackerName);
    }

    World.Territory storage target = territories.get(targetName);
    if (target.population == 0) {
      revert TerritoryNotFound(targetName);
    }

    if (!attacker.isNeighbor(targetName)) {
      if (warFunds < minWarFunds * 2) {
        revert NotEnoughFundsForWar(warFunds, minWarFunds * 2);
      }
      warFunds = warFunds - minWarFunds;
    }

    attacker.invest(warFunds);
    emit TerritoryInvested(attacker.name, msg.sender, warFunds);

    (uint64 attackerToll, uint64 defenseToll) = attacker.attack(target);
    computeWarResult(attacker, attackerToll, target, defenseToll);
  }

  /**
   * @dev Compute the result of a war between two territories.
   * @dev The attacker and target territories are updated according to the result of the war.
   */
  function computeWarResult(
    World.Territory storage attacker,
    uint64 attackerToll,
    World.Territory storage target,
    uint64 defenseToll
  ) private {
    emit TerritoryAttacked(msg.sender, attacker.name, target.name);

    if (attackerToll > attacker.population) {
      emit TerritoryDestroyed(attacker.name, msg.sender);
      attackerToll = attacker.population;
      territories.remove(attacker.name);
    } else {
      attacker.population -= attackerToll;
    }

    if (defenseToll > target.population) {
      emit TerritoryDestroyed(target.name, msg.sender);
      defenseToll = target.population;
      territories.remove(target.name);
    } else {
      target.population -= defenseToll;
    }

    totalPopulation -= attackerToll + defenseToll;
  }

  /**
   * @notice Withdraw the contract's balance to the owner. Anyone can call this function.
   */
  function withdraw() external {
    payable(owner()).transfer(address(this).balance);
  }

  function getTerritory(string calldata name) external view returns (World.Territory memory) {
    return territories.get(name);
  }
}
