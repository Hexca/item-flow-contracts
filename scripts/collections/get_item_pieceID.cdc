import Item from 0xITEMADDRESS

// This script gets the pieceID associated with a item
// in a collection by getting a reference to the item
// and then looking up its pieceID 

// Parameters:
//
// account: The Flow Address of the account whose item data needs to be read
// id: The unique ID for the item whose data needs to be read

// Returns: UInt32
// The pieceID associated with a item with a specified ID

pub fun main(account: Address, id: UInt64): UInt32 {

    // borrow a public reference to the owner's item collection 
    let collectionRef = getAccount(account).getCapability(Item.CollectionPublicPath)
        .borrow<&{Item.ItemCollectionPublic}>()
        ?? panic("Could not get public Item collection reference")

    // borrow a reference to the specified Item in the collection
    let token = collectionRef.borrowItem(id: id)
        ?? panic("Could not borrow a reference to the specified Item")

    let data = token.data

    return data.pieceID
}