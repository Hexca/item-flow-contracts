import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import ItemsWithOrg from "../../contracts/ItemsWithOrg.cdc"
import FungibleToken from "../../contracts/FungibleToken.cdc"
import FlowToken from "../../contracts/FlowToken.cdc"
import NFTStorefront from "../../contracts/NFTStorefront.cdc"

// This transction uses the NFTMinter resource to mint a new NFT.

transaction(recipient: Address, metadata: {String:String}, royalties: [ItemsWithOrg.Royalty]) {

    // local variable for storing the minter reference
    let minter: &ItemsWithOrg.NFTMinter
    let flowReceiver: Capability<&FlowToken.Vault{FungibleToken.Receiver}>
    let ItemsProvider: Capability<&ItemsWithOrg.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
    let storefront: &NFTStorefront.Storefront
    let saleCuts: [NFTStorefront.SaleCut]


    prepare(signer: AuthAccount) {

        // borrow a reference to the NFTMinter resource in storage
        self.minter = signer.borrow<&ItemsWithOrg.NFTMinter>(from: ItemsWithOrg.MinterStoragePath)
            ?? panic("Could not borrow a reference to the NFT minter")

         // We need a provider capability, but one is not provided by default so we create one if needed.
        let ItemsWithOrgCollectionProviderPrivatePath = /private/ItemsWithOrgCollectionProvider

        self.flowReceiver = signer.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)!

        assert(self.flowReceiver.borrow() != nil, message: "Missing or mis-typed FLOW receiver")

        if !signer.getCapability<&ItemsWithOrg.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(ItemsWithOrgCollectionProviderPrivatePath)!.check() {
            signer.link<&ItemsWithOrg.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(ItemsWithOrgCollectionProviderPrivatePath, target: ItemsWithOrg.CollectionStoragePath)
        }

        self.ItemsProvider = signer.getCapability<&ItemsWithOrg.Collection{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(ItemsWithOrgCollectionProviderPrivatePath)!

        assert(self.ItemsProvider.borrow() != nil, message: "Missing or mis-typed Items.Collection provider")

        self.storefront = signer.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath)
            ?? panic("Missing or mis-typed NFTStorefront Storefront")

        self.saleCuts = []
        let totalRoyaltiesRate = 0;
        for royalty in royalties {
            assert(royalty.rate >= 0.0 && royalty.rate < 1.0, message: "Sum of payouts must be in range [0..1)")
            self.saleCuts.append(NFTStorefront.SaleCut(royalty.address, saleItemPrice * royalty.rate))
            totalRoyaltiesRate = royalty.rate
        }

        let saleCut = NFTStorefront.SaleCut(
            receiver: self.flowReceiver,
            amount: saleItemPrice * (1.0 - totalRoyaltiesRate)
        )
        self.saleCuts.append(saleCut)
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
        // let kindValue = Items.Kind(rawValue: kind) ?? panic("invalid kind")
        // let rarityValue = Items.Rarity(rawValue: rarity) ?? panic("invalid rarity")

        // mint the NFT and deposit it to the recipient's collection
        self.minter.mintNFT(
            recipient: receiver,
            metadata: metadata,
            royalties: royalties
        )

        // let saleCut = NFTStorefront.SaleCut(
        //     receiver: self.flowReceiver,
        //     amount: 1.0,
        // )
        
        self.storefront.createListing(
            nftProviderCapability: self.ItemsProvider,
            nftType: Type<@ItemsWithOrg.NFT>(),
            nftID: ItemsWithOrg.totalSupply - 1,
            salePaymentVaultType: Type<@FlowToken.Vault>(),
            saleCuts: saleCuts
        )
    }
}
