import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import Items from "../../contracts/Items.cdc"

// This script returns the size of an account's Items collection.

pub fun main(address: Address): Int {
    let account = getAccount(address)

    let collectionRef = account.getCapability(Items.CollectionPublicPath)!
        .borrow<&{NonFungibleToken.CollectionPublic}>()
        ?? panic("Could not borrow capability from public collection")
    
    return collectionRef.getIDs().length
}
