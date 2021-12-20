import Items from 0xITEMADDRESS

// This script returns all the metadata about the specified piece

// Parameters:
//
// pieceID: The unique ID for the piece whose data needs to be read

// Returns: Items.QueryPieceData

pub fun main(pieceID: UInt32): Items.QueryPieceData {

    let data = Items.getPieceData(pieceID: pieceID)
        ?? panic("Could not get data for the specified piece ID")

    return data
}
