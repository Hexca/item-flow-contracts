import Items from 0xITEMADDRESS

// This script gets the metadata associated with an artist
// in a collection by looking up its playID and then searching
// for that play's metadata in the Items contract

// Parameters:
//
// account: The Flow Address of the account whose item data needs to be read
// id: The unique ID for the item whose data needs to be read

// Returns: {String: String} 
// A dictionary of all the artist metadata associated
// with the specified item

pub fun main(account: Address, id: UInt64): {String: String} {

    // get the public capability for the owner's item collection
    // and borrow a reference to it
    let collectionRef = getAccount(account).getCapability(Items.CollectionPublicPath)
        .borrow<&{Items.ItemsCollectionPublic}>()
        ?? panic("Could not get public item collection reference")

    // Borrow a reference to the specified item
    let token = collectionRef.borrowItems(id: id)
        ?? panic("Could not borrow a reference to the specified item")

    let data = token.data

    // Use the item's artist ID 
    // to get all the metadata associated with that artist
    let metadata = Items.getArtistMetaData(artistID: data.artistID) ?? panic("Artist doesn't exist")

    log(metadata)

    return metadata
}
