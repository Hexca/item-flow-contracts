import Item from 0xITEMADDRESS

// This script reads the current number of items that have been minted
// from the Item contract and returns that number to the caller

// Returns: UInt64
// Number of items minted from Item contract

pub fun main(): UInt64 {

    return Item.totalSupply
}