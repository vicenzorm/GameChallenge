//
//  EnemyAISystem.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 12/03/26.
//

import SpriteKit
import CoreMotion
import Foundation

class EnemyAISystem {
    func update(
        enemies: [Entity],
        playerEntity: Entity,
        deltaTime: TimeInterval,
        currentTime: TimeInterval,                    // ← novo parâmetro
        onEnemyShoot: ((Entity, CGVector) -> Void)?   // ← callback de tiro
    ) {
        guard let playerTransform = playerEntity.get(TransformComponent.self) else { return }
        let playerPos = playerTransform.node.position

        for enemy in enemies {
            guard
                let transform  = enemy.get(TransformComponent.self),
                let movement   = enemy.get(MovementComponent.self),
                let enemyComp  = enemy.get(EnemyComponent.self)
            else { continue }

            let toPlayer = CGVector(
                dx: playerPos.x - transform.node.position.x,
                dy: playerPos.y - transform.node.position.y
            )
            let dist = sqrt(toPlayer.dx * toPlayer.dx + toPlayer.dy * toPlayer.dy)
            let dir  = dist > 0
                ? CGVector(dx: toPlayer.dx / dist, dy: toPlayer.dy / dist)
                : .zero

            if enemyComp.type.canShoot {
                // No loop de enemies, antes do bloco de tiro, adicione:
                if !enemyComp.canPlayAttackSound {
                    enemyComp.attackSoundCooldown -= deltaTime
                    if enemyComp.attackSoundCooldown <= 0 {
                        enemyComp.canPlayAttackSound = true
                    }
                }
                // Shooter/boss mantém distância preferida do player
                if dist > enemyComp.type.preferredRange {
                    // Ainda longe — se aproxima
                    movement.velocity = CGVector(
                        dx: dir.dx * movement.speed,
                        dy: dir.dy * movement.speed
                    )
                } else if dist < enemyComp.type.preferredRange * 0.7 {
                    // Muito perto — recua
                    movement.velocity = CGVector(
                        dx: -dir.dx * movement.speed,
                        dy: -dir.dy * movement.speed
                    )
                } else {
                    // Na faixa ideal — para e atira
                    movement.velocity = .zero
                }

                // Tiro
                if currentTime - enemyComp.lastShotTime >= enemyComp.type.shootCooldown {
                    enemyComp.lastShotTime = currentTime
                    onEnemyShoot?(enemy, dir)
                }

            } else {
                // Comportamento padrão: persegue o player
                movement.velocity = CGVector(
                    dx: dir.dx * movement.speed,
                    dy: dir.dy * movement.speed
                )
            }
        }
    }
}
