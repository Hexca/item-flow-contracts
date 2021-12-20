import Items from 0xITEMADDRESS

// This transaction creates a new artist 
// and stores it in the Items smart contract
// We currently stringify the metadata and insert it into the 
// transaction string, but want to use transaction arguments soon

// Parameters:
//
// metadata: A dictionary of all the artist metadata associated

transaction(metadata: {String: String}) {

    // Local variable for the Items Admin object
    let adminRef: &Items.Admin
    let currArtistID: UInt32

    prepare(acct: AuthAccount) {

        // borrow a reference to the admin resource
        self.currArtistID = Items.nextArtistID;
        self.adminRef = acct.borrow<&Items.Admin>(from: Items.ItemsAdminStoragePath)
            ?? panic("No admin resource in storage")
    }

    execute {

        // Create a Artist with the specified metadata
        self.adminRef.createArtist(metadata: metadata)
    }

    post {
        
        Items.getArtistMetaData(artistID: self.currArtistID) != nil:
            "artistID doesnt exist"
    }
}
