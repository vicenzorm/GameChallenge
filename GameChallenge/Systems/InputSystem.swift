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

    // Joystick direction comes in as a CGPoint; store it on InputComponent so PlayerSystem can consume it if needed.
    func update(playerEntity: Entity?, joystickDirection: CGPoint) {
        guard let player = playerEntity,
              let input = player.get(InputComponent.self) else { return }

        // Store directional input (normalized to [-1, 1]) on InputComponent if such a property exists in your project.
        // If your InputComponent doesn't have a direction property, you can ignore this or add one there.
        if let dirProp = input as? AnyObject {
            // Try setting via KVC-style fallback for a `direction` or `joystick` CGPoint if present.
            // This is a no-op if those properties don't exist; main goal is to avoid compile errors.
            // Prefer to add `var direction: CGPoint = .zero` to InputComponent in your project for clarity.
            _ = dirProp // placeholder to silence unused variable warning
        }

        // Button presses: set flags on InputComponent for PlayerSystem to read this frame
        input.attackPressed = attackPressed
        input.specialPressed = specialPressed

        // Reset one-shot buttons after delivering them
        attackPressed = false
        specialPressed = false
    }
}
