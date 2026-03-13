//
//  MovementSystem.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 12/03/26.
//

import SpriteKit
import CoreMotion
import Foundation

class MovementSystem {
    func update(entities: [Entity], deltaTime: TimeInterval) {
        for entity in entities {
            guard
                let transform = entity.get(TransformComponent.self),
                let movement  = entity.get(MovementComponent.self)
            else { continue }

            transform.node.position.x += movement.velocity.dx * CGFloat(deltaTime)
            transform.node.position.y += movement.velocity.dy * CGFloat(deltaTime)
        }
    }
}
