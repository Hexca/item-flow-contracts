import Items from 0xITEMADDRESS

// This is the script to get a list of all the items' ids an account owns
// Just change the argument to `getAccount` to whatever account you want
// and as long as they have a published Collection receiver, you can see
// the items they own.

// Parameters:
//
// account: The Flow Address of the account whose item data needs to be read

// Returns: [UInt64]
// list of all items' ids an account owns

pub fun main(account: Address): [UInt64] {

    let acct = getAccount(account)

    let collectionRef = acct.getCapability(Items.CollectionPublicPath)
                            .borrow<&{Items.ItemsCollectionPublic}>()!

    log(collectionRef.getIDs())

    return collectionRef.getIDs()
}
