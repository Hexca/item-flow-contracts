import FungibleToken from "../../contracts/FungibleToken.cdc"
import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import FlowToken from "../../contracts/FlowToken.cdc"
import ItemsWithOrg from "../../contracts/ItemsWithOrg.cdc"
import NFTStorefront from "../../contracts/NFTStorefront.cdc"

pub fun getOrCreateStorefront(account: AuthAccount): &NFTStorefront.Storefront {
    if let storefrontRef = account.borrow<&NFTStorefront.Storefront>(from: NFTStorefront.StorefrontStoragePath) {
        return storefrontRef
    }

    let storefront <- NFTStorefront.createStorefront()

    let storefrontRef = &storefront as &NFTStorefront.Storefront

    account.save(<-storefront, to: NFTStorefront.StorefrontStoragePath)

    account.link<&NFTStorefront.Storefront{NFTStorefront.StorefrontPublic}>(NFTStorefront.StorefrontPublicPath, target: NFTStorefront.StorefrontStoragePath)

    return storefrontRef
}

transaction(saleItemID: UInt64, saleItemPrice: UFix64, royaltiesMap: {Address:UFix64}) {

    let flowReceiver: Capability<&FlowToken.Vault{FungibleToken.Receiver}>
    let ItemsWithOrgProvider: Capability<&ItemsWithOrg.Collection{ItemsWithOrg.ItemsWithOrgCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
    let storefront: &NFTStorefront.Storefront
    let saleCuts: [NFTStorefront.SaleCut]

    prepare(account: AuthAccount) {
        // We need a provider capability, but one is not provided by default so we create one if needed.
        let ItemsWithOrgCollectionProviderPrivatePath = /private/ItemsWithOrgCollectionProvider

        self.flowReceiver = account.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)!

        assert(self.flowReceiver.borrow() != nil, message: "Missing or mis-typed FLOW receiver")

        if !account.getCapability<&ItemsWithOrg.Collection{ItemsWithOrg.ItemsWithOrgCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(ItemsWithOrgCollectionProviderPrivatePath)!.check() {
            account.link<&ItemsWithOrg.Collection{ItemsWithOrg.ItemsWithOrgCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(ItemsWithOrgCollectionProviderPrivatePath, target: ItemsWithOrg.CollectionStoragePath)
        }

        self.ItemsWithOrgProvider = account.getCapability<&ItemsWithOrg.Collection{ItemsWithOrg.ItemsWithOrgCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(ItemsWithOrgCollectionProviderPrivatePath)!

        assert(self.ItemsWithOrgProvider.borrow() != nil, message: "Missing or mis-typed ItemsWithOrg.Collection provider")

        self.storefront = getOrCreateStorefront(account: account)

        self.saleCuts = []

        // self.nft = self.ItemsWithOrgProvider.borrow()!.borrowItem(id: saleItemID)

        // let royalties = self.nft!.getRoyalties();
        var totalRoyaltiesRate = 0.0;

        for key in royaltiesMap.keys {
            let value = royaltiesMap[key]!
            assert(value >= 0.0 && value < 1.0, message: "Sum of payouts must be in range [0..1)")
            let royaltyReceiver = getAccount(key).getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)!
            self.saleCuts.append(NFTStorefront.SaleCut(royaltyReceiver, saleItemPrice * value))
            totalRoyaltiesRate = totalRoyaltiesRate + value
        }


        let saleCut = NFTStorefront.SaleCut(
            receiver: self.flowReceiver,
            amount: saleItemPrice * (1.0 - totalRoyaltiesRate)
        )
        self.saleCuts.append(saleCut)
    }

    execute {        
        self.storefront.createListing(
            nftProviderCapability: self.ItemsWithOrgProvider,
            nftType: Type<@ItemsWithOrg.NFT>(),
            nftID: saleItemID,
            salePaymentVaultType: Type<@FlowToken.Vault>(),
            saleCuts: self.saleCuts
        )
    }
}
