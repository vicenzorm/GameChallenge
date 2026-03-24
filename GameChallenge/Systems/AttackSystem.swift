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
        let range  = isSpecial ? attackComp.range * 2.2 : attackComp.range
        let damage = isSpecial ? attackComp.damage * 20  : attackComp.damage
        
        let contactRadius: CGFloat = 38
        
        var didHitAny = false
        
        for enemy in enemies {
            guard
                let enemyTransform = enemy.get(TransformComponent.self),
                let health         = enemy.get(HealthComponent.self)
            else { continue }
            
            let toEnemy = enemyTransform.node.position - origin
            let dist    = toEnemy.length
            
            guard dist <= range else { continue }
            
            let inContactZone = dist <= contactRadius
            
            // Ataque normal: só acerta inimigos na metade frontal
            if !isSpecial && !inContactZone {
                let facingVector = sprite.lastDirection.vector
                let dot = facingVector.dx * toEnemy.normalized.dx
                + facingVector.dy * toEnemy.normalized.dy
                guard dot > 0 else { continue }
            }
            
            health.current = Swift.max(0, health.current - damage)
            
            if enemy.get(EnemyComponent.self) != nil {
                enemySystem.triggerDmg(enemy: enemy)
                SoundManager.shared.play(SoundManager.shared.hit1, on: enemyTransform.node)
            } else if enemy.get(BoxComponent.self) != nil {
                health.healthBarBackground?.run(.fadeIn(withDuration: 0.2))
                SoundManager.shared.play(SoundManager.shared.hit1, on: enemyTransform.node)
            }
            
            didHitAny = true
        }
        
        attackComp.didApplyDamage = true
    }
    
    // MARK: - Special Attack (giro 360)
    func startSpecialAttack(player: Entity, enemies: [Entity], scene: SKScene, enemySystem: EnemySystem) {
        guard
            let sprite    = player.get(SpriteComponent.self),
            let transform = player.get(TransformComponent.self),
            let attack    = player.get(AttackComponent.self)
        else { return }
        
        let node = transform.node
        
        attack.isAttacking     = true
        attack.didApplyDamage  = false
        
        // Animação de giro: percorre as 4 direções rapidamente
        let frames = [
            sprite.attackDownTextures[0],
            sprite.attackRightTextures[0],
            sprite.attackUpTextures[0],
            sprite.attackLeftTextures[0]
        ]
        
        let spinAnimation = SKAction.animate(with: frames, timePerFrame: 0.05)
        let totalSpin     = SKAction.repeat(spinAnimation, count: 3)
        let rotateNode    = SKAction.rotate(byAngle: .pi * 2, duration: 0.6)
        
        node.run(SKAction.group([totalSpin, rotateNode])) {
            attack.isAttacking = false
            node.zRotation     = 0
        }
        
        // Aplica dano omnidirecional imediatamente
        self.update(
            attackerEntity: player,
            enemies:        enemies,
            scene:          scene,
            isSpecial:      true,
            enemySystem:    enemySystem
        )
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

