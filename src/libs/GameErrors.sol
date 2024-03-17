// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24 <0.9.0;

interface GameErrors {
    /// @notice The territory does not exist or has been destroyed.
    /// @param name The name of the territory
    error TerritoryNotFound(string name);

    /// @notice The territory does not have enough population to perform the action.
    /// @param current The current population
    /// @param required The minimum population required
    error NotEnoughPopulation(uint64 current, uint64 required);

    /// @notice The given funds are not enough to trigger a war
    /// @param current The value sent
    /// @param required The minimum value required
    error NotEnoughFundsForWar(uint256 current, uint256 required);

    /// @notice Send some value to invest in the territory
    error MissingInvestmentValue();

    /// @notice The minimum war funds required to trigger a war is too low
    error MinWarFundsTooLow(uint256 min);
}
