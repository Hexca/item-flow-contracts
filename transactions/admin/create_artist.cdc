import Item from 0xITEMADDRESS

// This transaction creates a new artist 
// and stores it in the Item smart contract
// We currently stringify the metadata and insert it into the 
// transaction string, but want to use transaction arguments soon

// Parameters:
//
// metadata: A dictionary of all the artist metadata associated

transaction(metadata: {String: String}) {

    // Local variable for the Item Admin object
    let adminRef: &Item.Admin
    let currArtistID: UInt32

    prepare(acct: AuthAccount) {

        // borrow a reference to the admin resource
        self.currArtistID = Item.nextArtistID;
        self.adminRef = acct.borrow<&Item.Admin>(from: Item.ItemAdminStoragePath)
            ?? panic("No admin resource in storage")
    }

    execute {

        // Create a Artist with the specified metadata
        self.adminRef.createArtist(metadata: metadata)
    }

    post {
        
        Item.getArtistMetaData(artistID: self.currArtistID) != nil:
            "artistID doesnt exist"
    }
}