// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.24;

import { Test } from "forge-std/Test.sol";
// import { console2 } from "forge-std/src/console2.sol";
// import { StdCheats } from "forge-std/src/StdCheats.sol";
import { Upgrades } from "openzeppelin-foundry-upgrades/Upgrades.sol";
import { Options } from "openzeppelin-foundry-upgrades/Options.sol";

import { EndWarV1 } from "../src/EndWarV1.sol";
import { World } from "../src/libs/World.sol";

address constant ownerAddress = address(0x1);

contract EndWarTest is Test {
    EndWarV1 internal endWar;

    function setUp() public virtual {
        Options memory options;
        // TODO remove this unsafeSkipAllChecks
        options.unsafeSkipAllChecks = true;
        address proxy = Upgrades.deployTransparentProxy(
            "EndWarV1.sol", ownerAddress, abi.encodeCall(EndWarV1.initialize, (ownerAddress)), options
        );
        endWar = EndWarV1(proxy);
    }

    function test_intialTerritories() external view {
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
}
