# End War

This is a game to try out Solidity capabilities and the Ethereum blockchain.

The game simulates a world where wars spawn out of nowhere or are requested by players to end with the people's peace. The goal is to end the war, but until it happens, the war will continue to consume resources and lives. Players can only spend resources (ETH or other EVM compatible token) to end or start a war. The game ends if all people die or are part of the same nation. 

All money stored in the contract can only be withdrawn **by the deployer of the contract**.

It's like a war: everybody involved loses, except for the winning people on top - in this case, the deployer of the contract.

## Development

This repo used [Paul Berg's Template](https://github.com/PaulRBerg/foundry-template) as template for some good defaults, but I reverted back to Foundry's default Test library (out of PBTests).

## Run

Install Foundry: https://book.getfoundry.sh/getting-started/installation

### Tests

```bash
forge clean && forge test --ffi
```

### Deploy

```bash
forge build --optimize --ast
```

Create a .env file with the following content:

```bash
export ETHERSCAN_API_KEY=SOMETHING
export SEPOLIA_RPC_URL=https://url.com/api-key
export PUBLIC_KEY=0x111
export PRIVATE_KEY=123
```

#### Local server

Run 

```
anvil
```
Update the .env file with the local server URL and one of the public and private keys given by Anvil. Then run:

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
forge script script/Deploy.s.sol:Deploy --ffi --broadcast --verify -vvvv --rpc-url "$SEPOLIA_RPC_URL" --private-key "$PRIVATE_KEY"
```

The game is deployed to Sepolia testnet.

The following are the contract addresses with their Etherscan links:

- Proxy: [0x3b674b25402b2f0744940802a878588f2665c170](https://sepolia.etherscan.io/address/0x3b674b25402b2f0744940802a878588f2665c170)
- ProxyAdmin: [0x7296aa8b816b3217b8879609a61f5830f524b91d](https://sepolia.etherscan.io/address/0x7296aa8b816b3217b8879609a61f5830f524b91d)
- EndWar Implementation: [0xac9b785d8db677d7a9fd34a51c0f2001793d15c2](https://sepolia.etherscan.io/address/0xac9b785d8db677d7a9fd34a51c0f2001793d15c2)

You can use Etherscan to interact with the contract. Go to the [Proxy's ](https://sepolia.etherscan.io/address/0x3b674b25402b2f0744940802a878588f2665c170)
