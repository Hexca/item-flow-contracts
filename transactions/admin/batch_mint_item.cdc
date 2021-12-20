import Items from 0xITEMADDRESS

// This transaction mints multiple Itemss 
// from a single piece

// Parameters:
//
// pieceID: the ID of the Piece from which the Itemss are minted 
// quantity: the quantity of Itemss to be minted
// recipientAddr: the Flow address of the account receiving the collection of minted Itemss

transaction(pieceID: UInt32, quantity: UInt64, recipientAddr: Address) {

    // Local variable for the Items Admin object
    let adminRef: &Items.Admin

    prepare(acct: AuthAccount) {

        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&Items.Admin>(from: Items.ItemsAdminStoragePath)!
    }

    execute {

        // borrow a reference to the piece to be minted from
        let pieceRef = self.adminRef.borrowPiece(pieceID: pieceID)

        // Mint all the new NFTs
        let collection <- pieceRef.batchMintItems(quantity: quantity)

        // Get the account object for the recipient of the minted tokens
        let recipient = getAccount(recipientAddr)

        // get the Collection reference for the receiver
        let receiverRef = recipient.getCapability(Items.CollectionPublicPath).borrow<&{Items.ItemsCollectionPublic}>()
            ?? panic("Cannot borrow a reference to the recipient's collection")

        // deposit the NFT in the receivers collection
        receiverRef.batchDeposit(tokens: <-collection)
    }
}
