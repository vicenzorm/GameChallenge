//
//  ItemComponent.swift
//  GameChallenge
//
//  Created by Leonel Ferraz Hernandez on 17/03/26.
//

import Foundation

class ItemComponent: Component{
    enum ItemType{
        case healthPotion
        case specialCharge
        case killAll
        case shuriken
    }
    
    let type: ItemType
    let rarity: CGFloat
    
    init(type: ItemType, rarity: CGFloat) {
        self.type = type
        self.rarity = rarity
    }
}
