import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import Items from "../../contracts/Items.cdc"

// This transaction configures an account to hold Kitty Items.

transaction {
    prepare(signer: AuthAccount) {
        // if the account doesn't already have a collection
        if signer.borrow<&Items.Collection>(from: Items.CollectionStoragePath) == nil {

            // create a new empty collection
            let collection <- Items.createEmptyCollection()
            
            // save it to the account
            signer.save(<-collection, to: Items.CollectionStoragePath)

            // create a public capability for the collection
            signer.link<&Items.Collection{NonFungibleToken.CollectionPublic, Items.ItemsCollectionPublic}>(Items.CollectionPublicPath, target: Items.CollectionStoragePath)
        }
    }
}
