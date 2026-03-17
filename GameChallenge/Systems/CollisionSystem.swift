//
//  CollisionSystem.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 12/03/26.
//

import SpriteKit
import CoreMotion
import Foundation

class CollisionSystem {
    func checkEnemyPlayerCollisions(
        playerEntity: Entity,
        enemies: [Entity],
        deltaTime: TimeInterval,
        enemySystem: EnemySystem,
        soundManager: SoundManager = .shared    // ← novo parâmetro com default
    ) {
        guard
            let playerTransform = playerEntity.get(TransformComponent.self),
            let playerHealth    = playerEntity.get(HealthComponent.self)
        else { return }

        let pPos = playerTransform.node.position

        for enemy in enemies {
            guard
                let enemyTransform = enemy.get(TransformComponent.self),
                let enemyComp      = enemy.get(EnemyComponent.self)
            else { continue }

            let minDist: CGFloat = 24 + enemyComp.type.radius
            guard pPos.distance(to: enemyTransform.node.position) < minDist else { continue }

            playerHealth.current = Swift.max(0,
                playerHealth.current - enemyComp.type.damage * CGFloat(deltaTime))

            // Animação de ataque
            enemySystem.triggerSkeletonAtk(enemy: enemy)

            // Som de ataque por tipo — throttle via EnemyComponent para não repetir todo frame
            if enemyComp.canPlayAttackSound {
                enemyComp.canPlayAttackSound = false
                enemyComp.attackSoundCooldown = 0.5   // segundos antes de poder tocar de novo

                switch enemyComp.type {
                case .weak:
                    soundManager.play(soundManager.swordAttack1, on: enemyTransform.node)
                case .normal:
                    soundManager.play(soundManager.swordAttack2, on: enemyTransform.node)
                case .strong, .shooter, .boss:
                    soundManager.play(soundManager.monsterBite, on: enemyTransform.node)
                }
            }
        }
    }

    func checkCoinCollection(playerEntity: Entity, coins: [Entity]) -> [Entity] {
        guard let playerTransform = playerEntity.get(TransformComponent.self) else { return [] }
        let pPos = playerTransform.node.position
        return coins.filter {
            guard let t = $0.get(TransformComponent.self) else { return false }
            return pPos.distance(to: t.node.position) < 32
        }
    }
}
