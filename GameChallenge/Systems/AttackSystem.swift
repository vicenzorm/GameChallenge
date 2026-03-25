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
        let range  = isSpecial ? attackComp.range * 1 : attackComp.range
        let damage = isSpecial ? attackComp.damage * 4  : attackComp.damage
        
        let contactRadius: CGFloat = 45
        
        var didHitAny = false
        
        for enemy in enemies {
                    guard
                        let enemyTransform = enemy.get(TransformComponent.self),
                        let health         = enemy.get(HealthComponent.self)
                    else { continue }

                    // 1. Pegamos o raio do inimigo (se for Box ou Enemy)
                    let enemyRadius: CGFloat
                    if let enemyComp = enemy.get(EnemyComponent.self) {
                        enemyRadius = enemyComp.type.radius
                    } else if let box = enemy.get(BoxComponent.self) {
                        enemyRadius = 25 // Valor fixo para caixas ou pegue do componente
                    } else {
                        enemyRadius = 20
                    }
                    
                    let toEnemyVector = enemyTransform.node.position - origin
                    let distToCenter  = toEnemyVector.length
                    
                    let effectiveDist = Swift.max(0, distToCenter - enemyRadius)
                    
                    // 2. Checa se está no alcance
                    guard effectiveDist <= range else { continue }
                    
                    // 3. Checa direção (apenas para ataque normal e se não estiver "dentro" do player)
                    if !isSpecial && distToCenter > contactRadius {
                        let facingVector = sprite.lastDirection.vector
                        let toEnemyDir = toEnemyVector.normalized
                        
                        // Se o inimigo está exatamente no mesmo ponto, toEnemyDir será zero.
                        // Nesse caso, o contato direto (contactRadius) já resolveu.
                        
                        let dot = facingVector.dx * toEnemyDir.dx + facingVector.dy * toEnemyDir.dy
                        
                        // 0.2 dá um arco de ataque mais generoso (aprox 160 graus na frente)
                        // Usar > 0 era muito restrito (exatos 90 graus).
                        guard dot > -0.2 else { continue }
                    }
                    
                    // 4. Aplica o dano
                    health.current = Swift.max(0, health.current - damage)
                    
                    if enemy.get(EnemyComponent.self) != nil {
                        enemySystem.triggerDmg(enemy: enemy)
                        SoundManager.shared.play(SoundManager.shared.hit1, on: enemyTransform.node)
                    } else if enemy.get(BoxComponent.self) != nil {
                        health.healthBarBackground?.run(.fadeIn(withDuration: 0.2))
                        if enemy.get(BoxComponent.self)?.obstacleType == .firecamp {
                            SoundManager.shared.play(SoundManager.shared.firePutOut, on: enemyTransform.node)
                        }
                            else if enemy.get(BoxComponent.self)?.obstacleType == .treasure {
                                SoundManager.shared.play(SoundManager.shared.hitBoxComponent, on: enemyTransform.node)
                                SoundManager.shared.play(SoundManager.shared.clinkingCoins, on: enemyTransform.node)
                            }
                        else if enemy.get(BoxComponent.self)?.obstacleType == .vase {
                            SoundManager.shared.play(SoundManager.shared.vaseBreak, on: enemyTransform.node)
                        }
                        
                        else {
                            SoundManager.shared.play(SoundManager.shared.hitBoxComponent, on: enemyTransform.node)
                        }
                    }
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

