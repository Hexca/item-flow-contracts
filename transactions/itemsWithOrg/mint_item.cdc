import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import ItemsWithOrg from "../../contracts/ItemsWithOrg.cdc"
import FungibleToken from "../../contracts/FungibleToken.cdc"

// This transction uses the NFTMinter resource to mint a new NFT.

pub fun hasItems(_ address: Address): Bool {
  return getAccount(address)
    .getCapability<&ItemsWithOrg.Collection{NonFungibleToken.CollectionPublic, ItemsWithOrg.ItemsWithOrgCollectionPublic}>(ItemsWithOrg.CollectionPublicPath)
    .check()
}

transaction(recipient: Address, metadata: {String:String}) {

    // local variable for storing the minter reference
    let minter: &ItemsWithOrg.NFTMinter

    prepare(signer: AuthAccount, orgSigner: AuthAccount) {

        // initialize the account
        if !hasItems(signer.address) {
            if signer.borrow<&ItemsWithOrg.Collection>(from: ItemsWithOrg.CollectionStoragePath) == nil {
                signer.save(<-ItemsWithOrg.createEmptyCollection(), to: ItemsWithOrg.CollectionStoragePath)
            }
            signer.unlink(ItemsWithOrg.CollectionPublicPath)
            signer.link<&ItemsWithOrg.Collection{NonFungibleToken.CollectionPublic, ItemsWithOrg.ItemsWithOrgCollectionPublic}>(ItemsWithOrg.CollectionPublicPath, target: ItemsWithOrg.CollectionStoragePath)
        }

        // borrow a reference to the NFTMinter resource in storage, create it if not exist
        let _minter = signer.borrow<&ItemsWithOrg.NFTMinter>(from: ItemsWithOrg.MinterStoragePath)
        if _minter == nil {
            let nftMinter <- ItemsWithOrg.createNFTMinter(orgAccount: orgSigner.address)
            signer.save(<-nftMinter, to: ItemsWithOrg.MinterStoragePath)
            signer.unlink(ItemsWithOrg.MinterPublicPath)
            signer.link<&ItemsWithOrg.NFTMinter{ItemsWithOrg.NFTMinterPublic}>(ItemsWithOrg.MinterPublicPath, target: ItemsWithOrg.MinterStoragePath)

            self.minter = signer.borrow<&ItemsWithOrg.NFTMinter>(from: ItemsWithOrg.MinterStoragePath)
            ?? panic("Failed to borrow NFTMinter after creating it")
        } else {
            self.minter = _minter!
        }

    }

    execute {
        // get the public account object for the recipient
        let recipient = getAccount(recipient)

        // borrow the recipient's public NFT collection reference
        let receiver = recipient
            .getCapability(ItemsWithOrg.CollectionPublicPath)!
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")

        // mint the NFT and deposit it to the recipient's collection
        self.minter.mintNFT(
            recipient: receiver,
            metadata:metadata
        )
    }
}
