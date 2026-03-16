//
//  InputSystem.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 12/03/26.
//

import SpriteKit
import CoreMotion
import Foundation

class InputSystem {
    var attackPressed = false
    var specialPressed = false

    func update(playerEntity: Entity?, movementDirection: CGPoint, attackDirection: CGPoint) {
        guard let player = playerEntity,
              let input = player.get(InputComponent.self) else { return }

        input.movementDirection = CGVector(dx: movementDirection.x, dy: movementDirection.y)
        input.attackDirection = CGVector(dx: attackDirection.x, dy: attackDirection.y)

        input.attackPressed = attackPressed
        input.specialPressed = specialPressed

        attackPressed = false
        specialPressed = false
    }
}
