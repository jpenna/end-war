# End War

This is a game to try out Solidity capabilities and the Ethereum blockchain.

The game simulates a world where wars spawn out of nowhere or are requested by players to end with the people's peace. The goal is to end the war, but until it happens, the war will continue to consume resources and lives. Players can only spend resources (ETH or other EVM compatible token) to end or start a war. The game ends if all people die or are part of the same nation. 

All money stored in the contract can only be withdrawn **by the deployer of the contract**.

It's like a war: everybody involved loses, except for the winning people on top - in this case, the deployer of the contract.

## Development

- [Paul Berg's Template](https://github.com/PaulRBerg/foundry-template)

## Run

Install Foundry: https://book.getfoundry.sh/getting-started/installation

### Tests

```bash
foundry test --ffi
```
