# Items NFT Ecosystem

`Items` is an ecosystem to onboard the next generation of NFT collectors. NFT
vendors and creators can create and sell NFTs with near zero friction through
one of our adapters and NFT collectors can purchase NFTs without interacting
with a blockchain or cryptocurrency until they want or need to through the use
of traditional payments infrastructure and custodial wallets.

## Addresses

| Contract     | Testnet              | Mainnet              |
|--------------|----------------------|----------------------|
| Items        | `0x9cd0adb2d2a239ae` | `TBD`                |
| ItemsWithOrg | `0x9cd0adb2d2a239ae` | `TBD`                |

## Contracts

`Items`: The main contract for creating NFTs, it's derived from
[KittyItems](https://github.com/onflow/kitty-items), the main change is it
makes the `NFTMinter` resource public, and adds a public function `CreateNFTMinter`.

`ItemsWithOrg`: Is similar to `Items` with the addition that the `NFTMinter`
resource is owned, and the creator's address is included in the `Minted` event.


# Development

## Dependencies

* [Flow cli](https://docs.onflow.org/flow-cli/install/) v0.31.1 is required to run the tests, we pin an alpha version of `flow-js-testing` that currently only works on that version of the cli.

## Setup

Run from the `./tests` directory:
```
$ yarn install
```

## Running tests

Run from the `./tests` directory:
```
$ yarn test
```


## Deploy contracts
cd tests
flow accounts add-contract ItemsWithOrg ../contracts/ItemsWithOrg.cdc --signer testnet-dev-account --network testnet
