// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24 <0.9.0;

library World {
    struct Territory {
        string name;
        uint64 population;
        string[] neighbors;
    }

    function addNeighbor(Territory storage self, Territory storage other) internal {
        self.neighbors.push(other.name);
        other.neighbors.push(self.name);
    }
}
