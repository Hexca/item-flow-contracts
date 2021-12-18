import Item from 0xITEMADDRESS

// This script returns a boolean indicating if the specified piece is locked
// meaning new plays cannot be added to it

// Parameters:
//
// pieceID: The unique ID for the piece whose data needs to be read

// Returns: Bool
// Whether specified piece is locked

pub fun main(pieceID: UInt32): Bool {

    let isLocked = Item.isPieceLocked(pieceID: pieceID)
        ?? panic("Could not find the specified piece")

    return isLocked
}