import Item from 0xITEMADDRESS

// This script reads the public nextArtistID from the Item contract

// Returns: UInt32
// the nextArtistID field in Item contract

pub fun main(): UInt32 {

    log(Item.nextArtistID)

    return Item.nextArtistID
}