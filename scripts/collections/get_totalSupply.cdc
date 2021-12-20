import Items from 0xITEMADDRESS

// This script reads the current number of items that have been minted
// from the Items contract and returns that number to the caller

// Returns: UInt64
// Number of items minted from Items contract

pub fun main(): UInt64 {

    return Items.totalSupply
}
