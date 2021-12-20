import Items from 0xITEMADDRESS

// This script gets the serial number of a item
// by borrowing a reference to the item 
// and returning its serial number

// Parameters:
//
// account: The Flow Address of the account whose item data needs to be read
// id: The unique ID for the item whose data needs to be read

// Returns: UInt32
// The serialNumber associated with a item with a specified ID

pub fun main(account: Address, id: UInt64): UInt32 {

    let collectionRef = getAccount(account).getCapability(Items.CollectionPublicPath)
        .borrow<&{Items.ItemsCollectionPublic}>()
        ?? panic("Could not get public item collection reference")

    let token = collectionRef.borrowItems(id: id)
        ?? panic("Could not borrow a reference to the specified item")

    let data = token.data

    return data.serialNumber
}
