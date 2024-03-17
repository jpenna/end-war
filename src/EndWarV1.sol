// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24 <0.9.0;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { console2 } from "forge-std/console2.sol";

import { World } from "./libs/World.sol";
import { IterableTerritoryMapping } from "./libs/IterableTerritoryMapping.sol";

contract EndWarV1 is Initializable, OwnableUpgradeable {
    using IterableTerritoryMapping for IterableTerritoryMapping.Map;
    using World for World.Territory;

    IterableTerritoryMapping.Map private territories;
    uint256 public totalPopulation;

    /// @notice The territory does not exist or has been destroyed.
    error TerritoryNotFound(string name);
    /// @notice The territory does not have enough population to perform the action.
    error NotEnoughPopulation(uint64 current, uint64 required);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);

        initializeTerritories();
    }

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

    function newTerritory(
        string memory name,
        uint64 population,
        string[] memory neighbors
    )
        private
        returns (World.Territory storage territory)
    {
        // TODO param requirements
        territory = territories.get(name);

        territory.name = name;
        territory.population = population;

        for (uint256 i = 0; i < neighbors.length; i++) {
            territory.addNeighbor(territories.get(neighbors[i]));
        }

        territories.set(name, territory);

        totalPopulation += population;
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
