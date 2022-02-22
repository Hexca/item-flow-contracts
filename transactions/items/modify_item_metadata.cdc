import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import Items from "../../contracts/Items.cdc"

// This transaction attemps to modify an Item's metadata, it should not work in practice.

transaction(itemId: UInt64) {
    prepare(signer: AuthAccount) {
        
        // get the recipients public account object
        // let recipient = getAccount(owner)

        // borrow a reference to the signer's NFT collection
        let collectionRef = signer.borrow<&Items.Collection>(from: Items.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")

        // borrow a public reference to the owner's collection
        // let depositRef = signer.getCapability(Items.CollectionPublicPath)!.borrow<&{NonFungibleToken.CollectionPublic}>()!

        // withdraw the NFT from the owner's collection
        let nft <- collectionRef.withdraw(withdrawID: itemId) as! @Items.NFT

        // modify the nft metadata
        nft.metadata["newField"] = "newmetadata"

        // Deposit the NFT back in the owner's collection
        collectionRef.deposit(token: <-nft)
    }
}
