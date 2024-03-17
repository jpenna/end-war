// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24 <0.9.0;

import { World } from "./World.sol";

interface GameEvents {
    /// @notice Emitted when a new territory is created
    /// @param name The name of the territory
    /// @param population The initial population
    event TerritoryCreated(string name, uint64 population);

    /// @notice Emitted when a territory is destroyed
    /// @param name The name of the territory
    /// @param mastermind The address of the person behind the destruction
    event TerritoryDestroyed(string name, address mastermind);

    /// @notice Emitted when a territory is attacked
    /// @param mastermind The address the person behind the attack
    /// @param attacker The attacker's territory name
    /// @param target The target's territory name
    event TerritoryAttacked(address mastermind, string attacker, string target);

    /// @notice Emitted when a territory is invested
    /// @param name The name of the territory
    /// @param investor The address of the investor
    /// @param value The value invested
    event TerritoryInvested(string name, address investor, uint256 value);
}
