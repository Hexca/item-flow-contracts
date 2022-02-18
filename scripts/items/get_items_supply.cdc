import Items from "../../contracts/Items.cdc"

// This scripts returns the number of Items currently in existence.

pub fun main(): UInt64 {    
    return Items.totalSupply
}
