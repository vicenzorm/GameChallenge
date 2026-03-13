//
//  PhysicsCategory.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 12/03/26.
//

import SpriteKit
import Foundation

// Collision category bitmasks
struct PhysicsCategory {
    static let none:    UInt32 = 0
    static let player:  UInt32 = 0b0001
    static let enemy:   UInt32 = 0b0010
    static let sword:   UInt32 = 0b0100
    static let coin:    UInt32 = 0b1000
}
