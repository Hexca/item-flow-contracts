import Items from 0xITEMADDRESS

// This script gets the item by its ID

// Parameters:
//
// account: The Flow Address of the account whose item data needs to be read
// id: The unique ID for the item whose data needs to be read

// Returns: &Items.NFT
// The item with a specified ID

pub fun main(account: Address, id: UInt64): &Items.NFT {

    let collectionRef = getAccount(account).getCapability(Items.CollectionPublicPath)
        .borrow<&{Items.ItemsCollectionPublic}>()
        ?? panic("Could not get public item collection reference")

    let token = collectionRef.borrowItems(id: id)
        ?? panic("Could not borrow a reference to the specified item")

    return token
}
