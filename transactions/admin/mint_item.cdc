import Items from 0xITEMADDRESS

// This transaction is what an admin would use to mint a single new item
// and deposit it in a user's collection

// Parameters:
//
// pieceID: the ID of a piece from which a new item is minted
// recipientAddr: the Flow address of the account receiving the newly minted item

transaction(pieceID: UInt32, recipientAddr: Address) {
    // local variable for the admin reference
    let adminRef: &Items.Admin

    prepare(acct: AuthAccount) {
        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&Items.Admin>(from: Items.ItemsAdminStoragePath)!
    }

    execute {
        // Borrow a reference to the specified piece
        let pieceRef = self.adminRef.borrowPiece(pieceID: pieceID)

        // Mint a new NFT
        let item1 <- pieceRef.mintItems()

        // get the public account object for the recipient
        let recipient = getAccount(recipientAddr)

        // get the Collection reference for the receiver
        let receiverRef = recipient.getCapability(Items.CollectionPublicPath).borrow<&{Items.ItemsCollectionPublic}>()
            ?? panic("Cannot borrow a reference to the recipient's item collection")

        // deposit the NFT in the receivers collection
        receiverRef.deposit(token: <-item1)
    }
}
