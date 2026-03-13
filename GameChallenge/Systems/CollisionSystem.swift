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
        deltaTime: TimeInterval
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
            if pPos.distance(to: enemyTransform.node.position) < minDist {
                playerHealth.current = Swift.max(0,
                    playerHealth.current - enemyComp.type.damage * CGFloat(deltaTime))
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
