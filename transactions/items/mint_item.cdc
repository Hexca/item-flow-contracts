import NonFungibleToken from 0xNonFungibleToken
import Items from 0xItems

import FungibleToken from 0xFungibleToken
import NFTStorefront from 0xNFTStorefront

// This transction uses the NFTMinter resource to mint a new NFT.

pub fun hasItems(_ address: Address): Bool {
  return getAccount(address)
    .getCapability<&Items.Collection{NonFungibleToken.CollectionPublic, Items.ItemsCollectionPublic}>(Items.CollectionPublicPath)
    .check()
}

pub fun hasStorefront(_ address: Address): Bool {
  return getAccount(address)
    .getCapability<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath)
    .check()
}

transaction(recipient: Address, metadata: {String:String}) {

    // local variable for storing the minter reference
    let minter: &Items.NFTMinter

    prepare(signer: AuthAccount) {

        // initialize the account
        if !hasItems(signer.address) {
        if signer.borrow<&Items.Collection>(from: Items.CollectionStoragePath) == nil {
            signer.save(<-Items.createEmptyCollection(), to: Items.CollectionStoragePath)
        }
        signer.unlink(Items.CollectionPublicPath)
        signer.link<&Items.Collection{NonFungibleToken.CollectionPublic, Items.ItemsCollectionPublic}>(Items.CollectionPublicPath, target: Items.CollectionStoragePath)
        }

        if !hasStorefront(signer.address) {
        if signer.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath) == nil {
            signer.save(<-NFTStorefront.createStorefront(), to: NFTStorefront.StorefrontStoragePath)
        }
        signer.unlink(NFTStorefront.StorefrontPublicPath)
        signer.link<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath, target: NFTStorefront.StorefrontStoragePath)
        }

        // borrow a reference to the NFTMinter resource in storage, create it if not exist
        let _minter = signer.borrow<&Items.NFTMinter>(from: Items.MinterStoragePath)
        if _minter == nil {
            let nftMinter <- Items.createNFTMinter()
            signer.save(<-nftMinter, to: Items.MinterStoragePath)
            signer.unlink(Items.MinterPublicPath)
            signer.link<&Items.NFTMinter{Items.NFTMinterPublic}>(Items.MinterPublicPath, target: Items.MinterStoragePath)

            self.minter = signer.borrow<&Items.NFTMinter>(from: Items.MinterStoragePath)
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
            .getCapability(Items.CollectionPublicPath)!
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")

        // mint the NFT and deposit it to the recipient's collection
        self.minter.mintNFT(
            recipient: receiver,
            metadata:metadata,
        )
    }
}
