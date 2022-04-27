import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import ItemsWithOrg from "../../contracts/ItemsWithOrg.cdc"

// This transaction configures an account to hold Kitty ItemsWithOrg.

transaction {
    prepare(signer: AuthAccount) {
        // if the account doesn't already have a collection
        if signer.borrow<&ItemsWithOrg.Collection>(from: ItemsWithOrg.CollectionStoragePath) == nil {

            // create a new empty collection
            let collection <- ItemsWithOrg.createEmptyCollection()
            
            // save it to the account
            signer.save(<-collection, to: ItemsWithOrg.CollectionStoragePath)

            // create a public capability for the collection
            signer.link<&ItemsWithOrg.Collection{NonFungibleToken.CollectionPublic, ItemsWithOrg.ItemsWithOrgCollectionPublic}>(ItemsWithOrg.CollectionPublicPath, target: ItemsWithOrg.CollectionStoragePath)
        }
    }
}
