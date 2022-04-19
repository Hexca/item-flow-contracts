import ItemsWithOrg from "../../contracts/ItemsWithOrg.cdc"

// This scripts returns the number of Items currently in existence.

pub fun main(): UInt64 {    
    return ItemsWithOrg.totalSupply
}
