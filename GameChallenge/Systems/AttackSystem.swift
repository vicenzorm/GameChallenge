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
    
    // Seu método update atualizado com uma pequena correção no didHitEnemy
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
        // Especial tem um alcance bem maior
        let range  = isSpecial ? attackComp.range * 2.2 : attackComp.range
        let damage = isSpecial ? attackComp.damage * 3  : attackComp.damage

        var didHitEnemy = false
        
        for enemy in enemies {
            guard
                let enemyTransform = enemy.get(TransformComponent.self),
                let health         = enemy.get(HealthComponent.self)
            else { continue }

            let toEnemy = enemyTransform.node.position - origin
            let dist    = toEnemy.length

            guard dist <= range else { continue }

            // Se NÃO for especial, checa se está na frente (dot product)
            if !isSpecial {
                let facingVector = sprite.lastDirection.vector
                let dot = facingVector.dx * toEnemy.normalized.dx
                        + facingVector.dy * toEnemy.normalized.dy
                guard dot > 0.5 else { continue } // 0.5 dá um arco de ~45 graus
            }

            health.current = Swift.max(0, health.current - damage)
            enemySystem.triggerDmg(enemy: enemy)
            didHitEnemy = true
        }
        
        if didHitEnemy {
            SoundManager.shared.play(SoundManager.shared.hit1, on: attackerTransform.node)
        }
        
        attackComp.didApplyDamage = true
    }

    // --- NOVO: Método para orquestrar a animação de giro ---
    func startSpecialAttack(player: Entity, enemies: [Entity], scene: SKScene, enemySystem: EnemySystem) {
        guard let sprite = player.get(SpriteComponent.self),
              let transform = player.get(TransformComponent.self),
              let attack = player.get(AttackComponent.self) else { return }
        
        let node = transform.node
        
        // 1. Prepara os componentes
        attack.isAttacking = true
        attack.didApplyDamage = false
        
        // 2. Cria a animação de "giro" usando frames das 4 direções
        // Ordem: Baixo -> Direita -> Cima -> Esquerda
        let frames = [
            sprite.attackDownTextures[0],
            sprite.attackRightTextures[0],
            sprite.attackUpTextures[0],
            sprite.attackLeftTextures[0]
        ]
        
        let spinAnimation = SKAction.animate(with: frames, timePerFrame: 0.05)
        let totalSpin = SKAction.repeat(spinAnimation, count: 3) // Gira 3 vezes bem rápido
        
        // 3. Efeito visual de rotação no próprio node para vender o "360"
        let rotateNode = SKAction.rotate(byAngle: .pi * 2, duration: 0.6)
        
        // 4. Executa
        node.run(SKAction.group([totalSpin, rotateNode])) {
            attack.isAttacking = false
            node.zRotation = 0 // Reset do angulo
        }
        
        // 5. Aplica o dano (chamando seu update com isSpecial: true)
        self.update(attackerEntity: player, enemies: enemies, scene: scene, isSpecial: true, enemySystem: enemySystem)
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
