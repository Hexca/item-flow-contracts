# Item NFT Ecosystem

`Item` is an ecosystem to onboard the next generation of NFT collectors. NFT
vendors and artists can create and sell NFTs with near zero friction through
one of our adapters and NFT collectors can purchase NFTs without interacting
with a blockchain or cryptocurrency until they want or need to.

## Addresses

| Contract     | Testnet              | Mainnet              |
|--------------|----------------------|----------------------|
| Item         | `0x3a74affa1231ce18` | `TBD`                |

## Contracts

`Item`: The main contract for creating NFTs

* `@Piece`: created by an artist and can have `Item.NFT`s minted from it until locked.
    `Piece`s contain metadata.

* `@NFT`: the main NFT resource. It contains references to the `Piece` it belongs to and
    the artist that created it.

* `@Collection`: allows an account to hold `NFT`s

* `@Admin`: a resource that grants the owner superuser permissions: to create `Artist`s,
    `Piece`s, and create other `Admin`s. The `Admin` may be removed in the future to
    allow open usage of the ecosystem.

# Development

## Setup

In order to hack on this project, clone the repo, then install the necessary node modules

Run from the `./test` directory:
```
$ yarn install
```

## Running tests

Run from the `./test` directory:
```
$ yarn test
```