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
    
    override init() {
        // Create base
        baseNode = SKSpriteNode(color: UIColor(white: 0.3, alpha: 0.5), size: CGSize(width: 100, height: 100))
        baseNode.name = "joystickBase"
        
        // Create stick
        stickNode = SKSpriteNode(color: UIColor(white: 0.8, alpha: 0.8), size: CGSize(width: 50, height: 50))
        stickNode.name = "joystickStick"
        
        super.init()
        
        // Make them circular
        baseNode.physicsBody = nil
        stickNode.physicsBody = nil
        
        // Add to node
        addChild(baseNode)
        addChild(stickNode)
        
        // Set zPosition to be above everything
        zPosition = 1000
        
        // Enable touch handling
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if trackingTouch != nil { return }
        
        for touch in touches {
            let location = touch.location(in: self)
            let distance = hypot(location.x, location.y)
            if distance <= radius + 30 {
                trackingTouch = touch
                isTouching = true
                updateStickPosition(with: location)
                break
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isTouching, let touch = trackingTouch, touches.contains(touch) else { return }
        let location = touch.location(in: self)
        updateStickPosition(with: location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = trackingTouch, touches.contains(touch) {
            resetJoystick()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = trackingTouch, touches.contains(touch) {
            resetJoystick()
        }
    }
    
    private func updateStickPosition(with location: CGPoint) {
        // Calculate distance from center
        let distance = hypot(location.x, location.y)
        
        if distance <= radius {
            // Stick within radius
            stickNode.position = location
            velocity = CGPoint(
                x: location.x / radius,
                y: location.y / radius
            )
        } else {
            // Stick at edge of radius
            let angle = atan2(location.y, location.x)
            stickNode.position = CGPoint(
                x: cos(angle) * radius,
                y: sin(angle) * radius
            )
            velocity = CGPoint(
                x: cos(angle),
                y: sin(angle)
            )
        }
        
        // Normalize velocity for consistent speed
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
