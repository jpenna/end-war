// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24 <0.9.0;

// Adapted from https://solidity-by-example.org/app/iterable-mapping

import { World } from "./World.sol";

library IterableTerritoryMapping {
    struct Map {
        string[] keys;
        mapping(string => World.Territory) values;
        mapping(string => uint256) indexOf;
        mapping(string => bool) inserted;
    }

    function get(Map storage map, string memory key) internal view returns (World.Territory storage) {
        return map.values[key];
    }

    function getKeyAtIndex(Map storage map, uint256 index) internal view returns (string storage) {
        return map.keys[index];
    }

    function size(Map storage map) internal view returns (uint256) {
        return map.keys.length;
    }

    function set(Map storage map, string memory key, World.Territory storage val) internal {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, string memory key) internal {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint256 index = map.indexOf[key];
        string storage lastKey = map.keys[map.keys.length - 1];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}
