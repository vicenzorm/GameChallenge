//
//  HealthComponent.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 12/03/26.
//

import SpriteKit
import Foundation

// Health
class HealthComponent: Component {
    var current: CGFloat
    var max: CGFloat
    var healthBarBackground: SKShapeNode?
    var healthBarFill: SKShapeNode?

    var isInvulnerable: Bool = false
    
    init(max: CGFloat) {
        self.max = max
        self.current = max
    }

    var ratio: CGFloat { current / max }
    var isAlive: Bool { current > 0 }
}

