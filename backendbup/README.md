# Hardhat-Foundry Hybrid Framework

## Best of Both Worlds

This framework allows you to use the deploying toolset from the Hardhat library along with the testing suites from Foundry.

https://hardhat.org/hardhat-runner/plugins/nomicfoundation-hardhat-foundry

## Getting Started

### Starting with Foundry

Add Hardhat to your dev dependencies:

```bash
forge init
```

### Integrating Hardhat
You will need to init a package.json:

```bash
yarn init -y
```
Then install hardhat:

```bash
yarn add -D hardhat
```

Once you've set up Hardhat, install the Hardhat-Foundry plugin:

```bash
yarn add --dev @nomicfoundation/hardhat-foundry
```

Then, add the following line to your `hardhat.config.ts` file:

```typescript
import "@nomicfoundation/hardhat-foundry";
```

### Starting with Hardhat

Add Hardhat to your dev dependencies:

```bash
yarn add --dev hardhat
```

### Integrating Foundry

Once you've set up Hardhat, install the Hardhat-Foundry plugin:

```bash
yarn add --dev @nomicfoundation/hardhat-foundry
```

Then, add the following line to your `hardhat.config.ts` file:

```typescript
import "@nomicfoundation/hardhat-foundry";
```

### Initialize Foundry

With those requirements in place, initialize Foundry:

```bash
npx hardhat init-foundry
```

## Usage

Now you can use both Hardhat and Foundry tools:

### Commands Comparison Table

| Task                         | Hardhat Command                 | Forge Command                |
| ---------------------------- | ------------------------------- | ---------------------------- |
| Compile Contracts            | `npx hardhat compile`           | `Forge build`                          |
| Run Tests                    | `npx hardhat test`              | `Forge test (-vv) options`           |
| Add OpenZeppelin Contracts   | `yarn add @openzeppelin/contracts` | `forge install OpenZeppelin/openzeppelin-contracts --no-commit` |
| Run Deployment Script        | `npx hardhat run scripts/deploy.ts` |`see Forge Deploy Example`                         |
| Launch Node                  | `npx hardhat node`              | `Anvil`                          |
|
| Deploy Contracts             | Custom Hardhat script           | See Forge Deploy Example Below|

#### Forge Deploy Example

```bash
forge create --rpc-url <your_rpc_url> \
    --constructor-args <args> \
    --private-key <your_private_key> \
    --etherscan-api-key <your_etherscan_api_key> \
    --verify \
    src/ContractName.sol:NameOfContract
```

(Additional information or usage guide for Anvil can be added here)

```
Debugging:

If forge install doesn't pull all libraries from repo
manual install:

forge install foundry-rs/forge-std
forge install dapphub/ds-test
````
