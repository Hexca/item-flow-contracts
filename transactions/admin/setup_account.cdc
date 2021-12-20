import NonFungibleToken from 0xNONFUNGIBLETOKENADDRESS
import Items from 0xITEMADDRESS

// This transaction configures an account to hold Itemss.

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
