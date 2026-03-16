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
        isSpecial: Bool = false
    ) {
        guard
            let attackComp        = attackerEntity.get(AttackComponent.self),
            attackComp.isAttacking,
            let attackerTransform = attackerEntity.get(TransformComponent.self),
            let sprite            = attackerEntity.get(SpriteComponent.self)
        else { return }

        let origin = attackerTransform.node.position
        let range  = isSpecial ? attackComp.range * 2.5 : attackComp.range
        let damage = isSpecial ? attackComp.damage * 3  : attackComp.damage

        for enemy in enemies {
            guard
                let enemyTransform = enemy.get(TransformComponent.self),
                let health         = enemy.get(HealthComponent.self)
            else { continue }

            let toEnemy = enemyTransform.node.position - origin
            let dist    = toEnemy.length

            guard dist <= range else { continue }

            // Ataque normal: só acerta inimigos na metade frontal (cone de 180°)
            if !isSpecial {
                let facingVector = sprite.lastDirection.vector
                let dot = facingVector.dx * toEnemy.normalized.dx
                        + facingVector.dy * toEnemy.normalized.dy
                guard dot > 0 else { continue }   // dot ≤ 0 → atrás do jogador, ignora
            }

            health.current = Swift.max(0, health.current - damage)
            enemyTransform.node.run(.sequence([
                .colorize(with: .red, colorBlendFactor: 1, duration: 0.05),
                .colorize(withColorBlendFactor: 0, duration: 0.1)
            ]))
        }
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
