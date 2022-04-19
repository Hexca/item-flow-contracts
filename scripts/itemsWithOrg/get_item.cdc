import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import MetadataViews from "../../contracts/MetadataViews.cdc"
import ItemsWithOrg from "../../contracts/ItemsWithOrg.cdc"

pub struct Item {
  pub let title: String
  pub let description: String
  pub let imageURL: String
  pub let maxQuantity: String
  pub var royaltyPercentage: String?
  pub let orgAccount: address
  
  pub let itemID: UInt64
  pub let owner: Address

  init(
    itemID: UInt64,
    owner: Address,
    metadata: {String:String},
    orgAccount: address
  ) {
    self.itemID = itemID
    self.owner = owner

    self.title = metadata["title"]!
    self.description = metadata["description"]!
    self.imageURL = metadata["image"]!
    self.maxQuantity = metadata["maxQuantity"]!

    self.royaltyPercentage = metadata["royalty"]
      ?? metadata["royaltyPercentage"]

    self.orgAccount = orgAccount
  }
}

pub fun dwebURL(_ file: MetadataViews.IPFSFile): String {
    var url = "https://"
        .concat(file.cid)
        .concat(".ipfs.dweb.link/")
    
    if let path = file.path {
        return url.concat(path)
    }
    
    return url
}

pub fun main(address: Address, itemID: UInt64): Item? {
  if let collection = getAccount(address).getCapability<&ItemsWithOrg.Collection{NonFungibleToken.CollectionPublic, ItemsWithOrg.ItemsWithOrgCollectionPublic}>(ItemsWithOrg.CollectionPublicPath).borrow() {
    
    if let item = collection.borrowItem(id: itemID) {

      if let view = item.resolveView(Type<MetadataViews.Display>()) {

        let display = view as! MetadataViews.Display
        
        let owner: Address = item.owner!.address!
        let orgAccount: address = item.orgAccount!

        // let ipfsThumbnail = display.thumbnail as! MetadataViews.IPFSFile     

        return Item(
          itemID: itemID,
          owner: address,
          metadata: item.getMetadata(),
          orgAccount: orgAccount
        )
      }
    }
  }

    return nil
}
