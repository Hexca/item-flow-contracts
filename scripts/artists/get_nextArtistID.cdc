import Items from 0xITEMADDRESS

// This script reads the public nextArtistID from the Items contract

// Returns: UInt32
// the nextArtistID field in Items contract

pub fun main(): UInt32 {

    log(Items.nextArtistID)

    return Items.nextArtistID
}
