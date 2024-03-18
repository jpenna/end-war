# End War

This is a game ("wannabe") to try out Solidity capabilities and the Ethereum blockchain. It is deployed to the Sepolia testnet (read more [below](#Verify-on-Etherscan)) and implements the [Proxy Upgrade pattern](https://docs.openzeppelin.com/learn/upgrading-smart-contracts) to allow for upgrades.

The game simulates a world where wars can be requested by players to end with the people's peace. Players can only spend resources (ETH or other EVM compatible token) to end or start a war. The game ends if all people die or are part of the same nation, in which case only one territory is left and can't attack another.

> Wars should spawn automatically on player's interactions, but that will be left for another version.
> In this case, the goal is to end the wars that are never ending (just like our own world...).

All money stored in the contract can only be withdrawn **by the deployer of the contract**. It's like a war: everybody involved loses, except for the winning people on top - in this case, the deployer of the contract.

## Version 2

Just to test the deployment of a new version of the contract, I added a `getTerritoryUserFriendly` function that returns the all the information about a territory in a user-friendly way.

## Development

This repo used [Paul Berg's Template](https://github.com/PaulRBerg/foundry-template) as template for some good defaults, but I reverted back to Foundry's default Test library (out of PBTests).

## Run

Install Foundry: https://book.getfoundry.sh/getting-started/installation

### Tests

```bash
forge clean && forge test --ffi
```

### Build

```bash
forge build --ast
```


### Deploy

Copy `.env.example` to `.env` and fill in the values according to the environment (check below).

#### Local server

Run:

```bash
anvil
```

Update the .env file with the local server URL and one of the public and private keys given by Anvil. Something like this:

```bash
ETHERSCAN_API_KEY=SOMETHING # This can be ignored
# Just to make it simple, we will use $SEPOLIA_RPC_URL as the local server URL
SEPOLIA_RPC_URL=http://localhost:8545
# Copy from one of the accounts created by Anvil
PUBLIC_KEY=anvil_key 
PRIVATE_KEY=anvil_key
```

Then run:

```bash
source .env
forge script script/Deploy.s.sol:Deploy --ffi --broadcast -vvvv --fork-url "$SEPOLIA_RPC_URL" --private-key "$PRIVATE_KEY"
```

You can test the local deployment with: 

```bash
# Replace <contract_hash> with the contract hash returned by the deploy command
cast call <contract_hash> --rpc-url "$SEPOLIA_RPC_URL" --private-key "$PRIVATE_KEY" "totalPopulation()"
```

#### On-chain

Update the .env file with the public and private keys and the RPC URL. Then run:

```bash
source .env
forge clean
forge script script/Deploy.s.sol:Deploy --ffi --broadcast --verify -vvvv --rpc-url "$SEPOLIA_RPC_URL" --private-key "$PRIVATE_KEY"
```

### Upgrade

Modify the `Upgrade` contract in `script/Deploy.s.sol` with the correct values and run:

```bash
source .env
forge clean
forge script script/Deploy.s.sol:Upgrade --ffi --broadcast --verify -vvvv --rpc-url "$SEPOLIA_RPC_URL" --private-key "$PRIVATE_KEY"
```

#### Verify on Etherscan

The game is deployed to Sepolia testnet.

The following are the contract addresses with their Etherscan links:

- Proxy: [0x3ea7fd6a0b1023b9632edea7377dddc37bd86c8a](https://sepolia.etherscan.io/address/0x3ea7fd6a0b1023b9632edea7377dddc37bd86c8a)
- ProxyAdmin: [0xdba96a0680529da3df7da167097ca2da87e8824d](https://sepolia.etherscan.io/address/0xdba96a0680529da3df7da167097ca2da87e8824d)
- EndWar V1 Implementation: [0x2122b2fdce0b5e39f6ced7100fe324a8e55b5763](https://sepolia.etherscan.io/address/0x2122b2fdce0b5e39f6ced7100fe324a8e55b5763)
- EndWar V2 Implementation: [0x0b5d1f80e58a87c4150d8a188338712e718d63f3](https://sepolia.etherscan.io/address/0x0b5d1f80e58a87c4150d8a188338712e718d63f3)

You can use Etherscan to interact with the contract. Go to the [Proxy's page](https://sepolia.etherscan.io/address/0x3ea7fd6a0b1023b9632edea7377dddc37bd86c8a#readProxyContract), which is already connected to the EndWar implementation, and use the "Read as Proxy" and "Write as Proxy" sections to interact with the contract.
