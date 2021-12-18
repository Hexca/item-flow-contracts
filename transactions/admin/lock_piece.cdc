import Item from 0xITEMADDRESS

// This transaction locks a piece

// Parameters:
//
// pieceID: the ID of the piece to be locked

transaction(pieceID: UInt32) {

    // local variable for the admin resource
    let adminRef: &Item.Admin

    prepare(acct: AuthAccount) {
        // borrow a reference to the admin resource
        self.adminRef = acct.borrow<&Item.Admin>(from: Item.ItemAdminStoragePath)
            ?? panic("No admin resource in storage")
    }

    execute {
        // borrow a reference to the piece
        let pieceRef = self.adminRef.borrowPiece(pieceID: pieceID)

        // lock the piece permanently
        pieceRef.lock()
    }

    post {
        
        Item.isPieceLocked(pieceID: pieceID)!:
            "Piece did not lock"
    }
}