import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import ItemsWithOrg from "../../contracts/ItemsWithOrg.cdc"

// This scripts returns the number of ItemsWithOrg currently in existence.

pub fun main(address: Address, itemID: UInt64): {String: String} {
  if let collection = getAccount(address).getCapability<&ItemsWithOrg.Collection{NonFungibleToken.CollectionPublic, ItemsWithOrg.ItemsWithOrgCollectionPublic}>(ItemsWithOrg.CollectionPublicPath).borrow() {
    if let item = collection.borrowItem(id: itemID) {
        return item.getMetadata()
    }
  }

  return {}
}
