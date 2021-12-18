import Item from 0xITEMADDRESS

// This transaction is for the admin to create a new piece resource
// and store it in the top shot smart contract

// Parameters:
// artistID: the ID of the artist who created the piece
// metadata: A dictionary of all the piece metadata associated

transaction(artistID: UInt32, metadata: {String: String}) {
    
    // Local variable for the item Admin object
    let adminRef: &Item.Admin
    let currPieceID: UInt32

    prepare(acct: AuthAccount) {

        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&Item.Admin>(from: Item.ItemAdminStoragePath)
            ?? panic("Could not borrow a reference to the Admin resource")
        self.currPieceID = Item.nextPieceID;
    }

    execute {
        
        // Create a set with the specified name
        self.adminRef.createPiece(artistID: artistID, metadata:metadata)
    }

    post {
        
        Item.getPieceData(pieceID: self.currPieceID) != nil:
            "pieceID does not exist"
    }
}