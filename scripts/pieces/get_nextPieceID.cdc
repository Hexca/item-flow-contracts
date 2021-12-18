import Item from 0xITEMADDRESS

// This script reads the next Piece ID from the Item contract and 
// returns that number to the caller

// Returns: UInt32
// Value of nextPieceID field in Item contract

pub fun main(): UInt32 {

    log(Item.nextPieceID)

    return Item.nextPieceID
}