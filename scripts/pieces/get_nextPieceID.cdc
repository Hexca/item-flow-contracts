import Items from 0xITEMADDRESS

// This script reads the next Piece ID from the Items contract and 
// returns that number to the caller

// Returns: UInt32
// Value of nextPieceID field in Items contract

pub fun main(): UInt32 {

    log(Items.nextPieceID)

    return Items.nextPieceID
}
