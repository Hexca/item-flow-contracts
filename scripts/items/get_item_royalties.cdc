import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import Items from "../../contracts/Items.cdc"

// This scripts returns the number of Items currently in existence.

pub fun main(address: Address, itemID: UInt64): [Items.Royalty] {
  if let collection = getAccount(address).getCapability<&Items.Collection{NonFungibleToken.CollectionPublic, Items.ItemsCollectionPublic}>(Items.CollectionPublicPath).borrow() {
    if let item = collection.borrowItem(id: itemID) {
        return item.getRoyalties()
    }
  }

  return [Items.Royalty(address: address, rate: 0.1)]
}
