import Item from 0xITEMADDRESS

// This script returns true if a item with the specified ID
// exists in a user's collection

// Parameters:
//
// account: The Flow Address of the account whose item data needs to be read
// id: The unique ID for the item whose data needs to be read

// Returns: Bool
// Whether a item with specified ID exists in user's collection

pub fun main(account: Address, id: UInt64): Bool {

    let collectionRef = getAccount(account).getCapability(Item.CollectionPublicPath)
        .borrow<&{Item.ItemCollectionPublic}>()
        ?? panic("Could not get public item collection reference")

    return collectionRef.borrowNFT(id: id) != nil
}