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
    var shootPressed = false // NOVO

    func update(playerEntity: Entity?, movementDirection: CGPoint) {
        guard let player = playerEntity,
              let input = player.get(InputComponent.self) else { return }

        input.movementDirection = CGVector(dx: movementDirection.x, dy: movementDirection.y)
        
        input.attackPressed = attackPressed
        input.specialPressed = specialPressed

        if let attackComp = player.get(AttackComponent.self) {
            if shootPressed {
                
                attackComp.wantsToShoot = true
            }
        }

        attackPressed = false
        specialPressed = false
        shootPressed = false
    }
}
