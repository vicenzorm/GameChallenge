//
//  BoxSystem.swift
//  GameChallenge
//
//  Created by Bernardo Garcia Fensterseifer on 16/03/26.
//

import SpriteKit

// BoxSystem: resolves AABB collisions between any moving entity and every box.
// Call update() after MovementSystem so positions are already committed for the frame.
class BoxSystem {

    // MARK: - Public API
    
    private let hitboxScale: CGFloat = 0.6

    /// Pushes `movers` out of any box they overlap.
    /// - Parameters:
    ///   - movers:    Entities that can move (player + enemies).
    ///   - boxes:     All box entities in the scene.
    func update(movers: [Entity], boxes: [Entity]) {
        let boxRects = boxes.compactMap { boxRect(for: $0) }
        guard !boxRects.isEmpty else { return }

        for mover in movers {
            guard let transform = mover.get(TransformComponent.self) else { continue }
            let node = transform.node

            for boxRect in boxRects {
                resolve(node: node as! SKSpriteNode, against: boxRect)
            }
        }
    }

    // MARK: - Private helpers

    /// Returns the world-space CGRect of a box entity, or nil if it has no TransformComponent.
    private func boxRect(for box: Entity) -> CGRect? {
        guard let node = box.get(TransformComponent.self)?.node as? SKSpriteNode else { return nil }
        let w = node.size.width  * hitboxScale
        let h = node.size.height * hitboxScale
        return CGRect(
            x: node.position.x - w / 2,
            y: node.position.y - h / 2,
            width:  w,
            height: h
        )
    }

    /// Pushes `node` out of `boxRect` along the axis of least penetration.
    private func resolve(node: SKSpriteNode, against boxRect: CGRect) {
        let moverRect = CGRect(
            x: node.position.x - node.size.width  / 2,
            y: node.position.y - node.size.height / 2,
            width:  node.size.width,
            height: node.size.height
        )

        guard let intersection = moverRect.intersection(with: boxRect),
              !intersection.isNull,
              intersection.width > 0,
              intersection.height > 0
        else { return }

        // Push out along the shallowest axis
        if intersection.width < intersection.height {
            let pushX = node.position.x < boxRect.midX
                ? -intersection.width
                :  intersection.width
            node.position.x += pushX
        } else {
            let pushY = node.position.y < boxRect.midY
                ? -intersection.height
                :  intersection.height
            node.position.y += pushY
        }
    }
}

// MARK: - CGRect helper
private extension CGRect {
    /// Returns nil instead of a zero rect when there is no intersection.
    func intersection(with other: CGRect) -> CGRect? {
        let result = self.intersection(other)
        return result.isNull ? nil : result
    }
}
