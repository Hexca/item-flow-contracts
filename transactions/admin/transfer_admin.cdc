import Items from 0xITEMADDRESS
import ItemsAdminReceiver from 0xADMINRECEIVERADDRESS

// this transaction takes a Items Admin resource and 
// saves it to the account storage of the account
// where the contract is deployed

transaction {

    // Local variable for the Items Admin object
    let adminRef: @Items.Admin

    prepare(acct: AuthAccount) {

        self.adminRef <- acct.load<@Items.Admin>(from: Items.ItemsAdminStoragePath)
            ?? panic("No Items admin in storage")
    }

    execute {

        ItemsAdminReceiver.storeAdmin(newAdmin: <-self.adminRef)
        
    }
}
