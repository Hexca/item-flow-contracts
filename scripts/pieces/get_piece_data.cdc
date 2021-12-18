import Item from 0xITEMADDRESS

// This script returns all the metadata about the specified piece

// Parameters:
//
// pieceID: The unique ID for the piece whose data needs to be read

// Returns: Item.QueryPieceData

pub fun main(pieceID: UInt32): Item.QueryPieceData {

    let data = Item.getPieceData(pieceID: pieceID)
        ?? panic("Could not get data for the specified piece ID")

    return data
}