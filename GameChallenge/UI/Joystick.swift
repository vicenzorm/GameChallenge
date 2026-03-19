//
//  Joystick.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 11/03/26.
//

import SpriteKit

class Joystick: SKNode {
    private let baseNode: SKSpriteNode
    private let stickNode: SKSpriteNode
    private let radius: CGFloat = 50

    private var trackingTouch: UITouch?

    var velocity: CGPoint = .zero
    var isTouching = false

    /// - Parameters:
    ///   - baseAsset:  nome do asset para o disco externo (ex: "joystick_base")
    ///   - stickAsset: nome do asset para o knob interno (ex: "joystick_ball" ou "joystick_shuriken")
    init(baseAsset: String = "joystick_base", stickAsset: String = "joystick_ball") {
        // Base (anel externo)
        baseNode = SKSpriteNode(imageNamed: baseAsset)
        baseNode.name = "joystickBase"
        baseNode.size = CGSize(width: radius * 1.8, height: radius * 1.8)
        baseNode.zPosition = 999

        // Stick (knob interno — metade do raio da base)
        stickNode = SKSpriteNode(imageNamed: stickAsset)
        stickNode.name = "joystickStick"
        stickNode.size = CGSize(width: radius, height: radius)
        stickNode.zPosition = 1000
        
        super.init()

        addChild(baseNode)
        addChild(stickNode)

        zPosition = 1001
        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard trackingTouch == nil else { return }
        for touch in touches {
            let location = touch.location(in: self)
            if hypot(location.x, location.y) <= radius + 30 {
                trackingTouch = touch
                isTouching = true
                updateStickPosition(with: location)
                break
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isTouching, let touch = trackingTouch, touches.contains(touch) else { return }
        updateStickPosition(with: touch.location(in: self))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = trackingTouch, touches.contains(touch) { resetJoystick() }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = trackingTouch, touches.contains(touch) { resetJoystick() }
    }

    // MARK: - Private

    private func updateStickPosition(with location: CGPoint) {
        let distance = hypot(location.x, location.y)

        if distance <= radius {
            stickNode.position = location
            velocity = CGPoint(x: location.x / radius, y: location.y / radius)
        } else {
            let angle = atan2(location.y, location.x)
            stickNode.position = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
            velocity = CGPoint(x: cos(angle), y: sin(angle))
        }

        let magnitude = hypot(velocity.x, velocity.y)
        if magnitude > 0 {
            velocity.x /= magnitude
            velocity.y /= magnitude
        }
    }

    private func resetJoystick() {
        trackingTouch = nil
        isTouching = false
        stickNode.position = .zero
        velocity = .zero
    }
}
