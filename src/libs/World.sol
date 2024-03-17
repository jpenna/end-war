// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24 <0.9.0;

library World {
    struct Territory {
        string name;
        uint64 population;
        string[] neighbors;
        uint128 power;
    }

    function addNeighbor(Territory storage self, Territory storage other) internal {
        self.neighbors.push(other.name);
        other.neighbors.push(self.name);
    }

    function isNeighbor(Territory storage self, string memory targetName) internal view returns (bool) {
        bytes32 name = keccak256(abi.encodePacked(targetName));
        for (uint256 i = 0; i < self.neighbors.length; i++) {
            if (keccak256(abi.encodePacked(self.neighbors[i])) == name) {
                return true;
            }
        }
        return false;
    }

    function invest(Territory storage self, uint256 funds) internal {
        self.power += uint128(funds);
    }

    function attack(
        Territory storage attacker,
        Territory storage target
    )
        internal
        view
        returns (uint64 attackerToll, uint64 defenseToll)
    {
        // Will not overflow, since `population` is uint64 and `power` is uint128
        uint256 attackForce = uint256(attacker.population) * attacker.power;
        uint256 defenseForce = uint256(target.population) * target.power;

        uint64 diffImpact = uint64(attackForce / defenseForce);

        if (attackForce > defenseForce) {
            attackerToll = attacker.population * 10 / 100;
            defenseToll = target.population * 20 / 100 + diffImpact;
        } else {
            attackerToll = attacker.population * 10 / 100 + diffImpact;
            defenseToll = target.population * 5 / 100;
        }
    }
}
