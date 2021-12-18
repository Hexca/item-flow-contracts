import Item from 0xITEMADDRESS

// This script returns the full metadata associated with an artist
// in the Item smart contract

// Parameters:
//
// artistID: The unique ID for the artist

// Returns: {String:String}
// A dictionary of all the artist metadata associated
// with the specified artistID

pub fun main(artistID: UInt32): {String:String} {

    let metadata = Item.getArtistMetaData(artistID: artistID) ?? panic("Artist doesn't exist")

    log(metadata)

    return metadata
}