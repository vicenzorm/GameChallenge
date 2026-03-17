//
//  AttackSystem.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 12/03/26.
//

import SpriteKit
import CoreMotion
import Foundation

class AttackSystem {
    
    

    func update(
        attackerEntity: Entity,
        enemies: [Entity],
        scene: SKScene,
        isSpecial: Bool = false,
        enemySystem: EnemySystem
    ) {
        
        guard
            let attackComp        = attackerEntity.get(AttackComponent.self),
            attackComp.isAttacking,
            let attackerTransform = attackerEntity.get(TransformComponent.self),
            let sprite            = attackerEntity.get(SpriteComponent.self),
            !attackComp.didApplyDamage
        else { return }

        let origin = attackerTransform.node.position
        let range  = isSpecial ? attackComp.range * 2.5 : attackComp.range
        let damage = isSpecial ? attackComp.damage * 3  : attackComp.damage


        var didHitEnemy = false
        // Hit enemies in range
        for enemy in enemies {
                guard
                    let enemyTransform = enemy.get(TransformComponent.self),
                    let health         = enemy.get(HealthComponent.self)
                else { continue }

                let toEnemy = enemyTransform.node.position - origin
                let dist    = toEnemy.length

                guard dist <= range else { continue }

                if !isSpecial {
                    let facingVector = sprite.lastDirection.vector
                    let dot = facingVector.dx * toEnemy.normalized.dx
                            + facingVector.dy * toEnemy.normalized.dy
                    guard dot > 0 else { continue }
                }

                health.current = Swift.max(0, health.current - damage)
                enemySystem.triggerDmg(enemy: enemy)   // ← substitui o colorize antigo
            }
        
        if didHitEnemy {
            SoundManager.shared.play(SoundManager.shared.hit1, on: attackerTransform.node)
        }
        
        attackComp.didApplyDamage = true
    }
}

// MARK: - Helpers
private extension CGPoint {
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGVector {
        CGVector(dx: lhs.x - rhs.x, dy: lhs.y - rhs.y)
    }
}

private extension CGVector {
    var length: CGFloat { sqrt(dx*dx + dy*dy) }
    var normalized: CGVector {
        let l = length
        return l > 0 ? CGVector(dx: dx/l, dy: dy/l) : .zero
    }
}

// Converte a direção do sprite num vetor unitário para o dot product
extension SpriteComponent.Direction {
    var vector: CGVector {
        switch self {
        case .down:  return CGVector(dx:  0, dy: -1)
        case .up:    return CGVector(dx:  0, dy:  1)
        case .left:  return CGVector(dx: -1, dy:  0)
        case .right: return CGVector(dx:  1, dy:  0)
        }
    }
}
