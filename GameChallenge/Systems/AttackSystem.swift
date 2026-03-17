//
//  AttackSystem.swift
//  POC-2DGame
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

        var didHitAny = false

        for enemy in enemies {
            guard
                let enemyTransform = enemy.get(TransformComponent.self),
                let health         = enemy.get(HealthComponent.self)
            else { continue }

            let toEnemy = enemyTransform.node.position - origin
            let dist    = toEnemy.length

            guard dist <= range else { continue }

            // Ataque normal: só acerta inimigos na metade frontal
            if !isSpecial {
                let facingVector = sprite.lastDirection.vector
                let dot = facingVector.dx * toEnemy.normalized.dx
                        + facingVector.dy * toEnemy.normalized.dy
                guard dot > 0 else { continue }
            }

            // Aplica dano + animação + som por inimigo atingido
            health.current = Swift.max(0, health.current - damage)
            enemySystem.triggerDmg(enemy: enemy)
            SoundManager.shared.play(SoundManager.shared.hit1, on: enemyTransform.node)

            didHitAny = true
        }

        // Visual do hitbox — só aparece se acertou pelo menos um inimigo
        if didHitAny {
            attackComp.attackNode?.removeFromParent()
            let arc = SKShapeNode(circleOfRadius: range)
            arc.fillColor   = isSpecial
                ? UIColor.cyan.withAlphaComponent(0.25)
                : UIColor.white.withAlphaComponent(0.15)
            arc.strokeColor = isSpecial ? .cyan : .white
            arc.lineWidth   = 1.5
            arc.position    = origin
            arc.zPosition   = 5
            scene.addChild(arc)
            attackComp.attackNode = arc
            arc.run(.sequence([.fadeOut(withDuration: 0.2), .removeFromParent()]))
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
