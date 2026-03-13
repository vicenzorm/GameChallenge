//
//  MotionInputSystem.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 12/03/26.
//


import SpriteKit
import CoreMotion
import Foundation

// Replaces the joystick. Uses CMMotionManager to read device tilt.
class MotionInputSystem {
    private let motionManager = CMMotionManager()
    private(set) var direction: CGVector = .zero

    // Sensitivity: higher = faster response to tilt
    var sensitivity: Double = 3.5
    // Dead zone: ignore tiny device wobble
    var deadzone: Double = 0.04

    init() {
        guard motionManager.isAccelerometerAvailable else { return }
        motionManager.accelerometerUpdateInterval = 1.0 / 60.0
        motionManager.startAccelerometerUpdates()
    }

    deinit {
        motionManager.stopAccelerometerUpdates()
    }

    func update() {
        guard let data = motionManager.accelerometerData else {
            direction = .zero
            return
        }

        // In landscape-right: x-axis tilt → horizontal, y-axis tilt → vertical
        // Swap / negate axes based on your device orientation
        var dx = -data.acceleration.y * sensitivity  // tilt left/right (inverted)
        var dy =  data.acceleration.x * sensitivity  // tilt forward/back

        // Dead zone
        if abs(dx) < deadzone { dx = 0 }
        if abs(dy) < deadzone { dy = 0 }

        // Clamp to unit vector feel (-1…1)
        dx = max(-1, min(1, dx))
        dy = max(-1, min(1, dy))

        direction = CGVector(dx: dx, dy: dy)
    }
}
