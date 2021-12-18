import NonFungibleToken from 0xNONFUNGIBLETOKENADDRESS
import Item from 0xITEMADDRESS

// This transaction configures an account to hold Items.

transaction {
    prepare(signer: AuthAccount) {
        // if the account doesn't already have a collection
        if signer.borrow<&Item.Collection>(from: Item.CollectionStoragePath) == nil {

            // create a new empty collection
            let collection <- Item.createEmptyCollection()
            
            // save it to the account
            signer.save(<-collection, to: Item.CollectionStoragePath)

            // create a public capability for the collection
            signer.link<&Item.Collection{NonFungibleToken.CollectionPublic, Item.ItemCollectionPublic}>(Item.CollectionPublicPath, target: Item.CollectionStoragePath)
        }
    }
}