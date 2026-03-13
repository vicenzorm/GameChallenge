//
//  PlayerComponent.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 12/03/26.
//

import SpriteKit
import Foundation

// Player-specific
class PlayerComponent: Component {
    var coins: Int = 0
    var killStreak: Int = 0          // resets on use of special
    var specialReady: Bool = false

    // Special thresholds
    static let weakKillsNeeded = 5
    static let normalKillsNeeded = 3
    static let strongKillsNeeded = 1
}
