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
    func update(enemies: [Entity], playerEntity: Entity, deltaTime: TimeInterval) {
        guard let playerTransform = playerEntity.get(TransformComponent.self) else { return }
        let playerPos = playerTransform.node.position

        for enemy in enemies {
            guard
                let transform = enemy.get(TransformComponent.self),
                let movement  = enemy.get(MovementComponent.self)
            else { continue }

            let dx   = playerPos.x - transform.node.position.x
            let dy   = playerPos.y - transform.node.position.y
            let dist = sqrt(dx*dx + dy*dy)
            if dist > 1 {
                movement.velocity = CGVector(
                    dx: (dx / dist) * movement.speed,
                    dy: (dy / dist) * movement.speed
                )
            }
        }
    }
}
