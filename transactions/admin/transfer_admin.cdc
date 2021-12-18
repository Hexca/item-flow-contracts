import Item from 0xITEMADDRESS
import ItemAdminReceiver from 0xADMINRECEIVERADDRESS

// this transaction takes a Item Admin resource and 
// saves it to the account storage of the account
// where the contract is deployed

transaction {

    // Local variable for the Item Admin object
    let adminRef: @Item.Admin

    prepare(acct: AuthAccount) {

        self.adminRef <- acct.load<@Item.Admin>(from: Item.ItemAdminStoragePath)
            ?? panic("No Item admin in storage")
    }

    execute {

        ItemAdminReceiver.storeAdmin(newAdmin: <-self.adminRef)
        
    }
}