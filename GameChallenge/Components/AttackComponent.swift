//
//  AttackComponent.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 12/03/26.
//

import SpriteKit
import Foundation

// Attack / Hitbox
class AttackComponent: Component {
    var damage: CGFloat
    var range: CGFloat
    var cooldown: TimeInterval
    var lastAttackTime: TimeInterval = 0
    var isAttacking: Bool = false
    var attackNode: SKShapeNode?
    var didApplyDamage: Bool = false
    var wantsToShoot: Bool = false
    var shootDirection: CGVector = .zero
    var shootCooldown: TimeInterval = 1.0   // ← intervalo mínimo entre tiros (segundos)
    var lastShotTime:  TimeInterval = 0     // ← timestamp do último tiro disparado

    init(damage: CGFloat, range: CGFloat, cooldown: TimeInterval) {
        self.damage = damage
        self.range = range
        self.cooldown = cooldown
    }
}
