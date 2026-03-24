//
//  FloatingJoystick.swift
//  GameChallenge
//
//  Created by Vicenzo Másera on 23/03/26.
//


import SpriteKit

class FloatingJoystick: SKNode {
    private let baseNode: SKSpriteNode
    private let stickNode: SKSpriteNode
    private let radius: CGFloat = 50

    private var trackingTouch: UITouch?
    var velocity: CGPoint = .zero
    var isTouching = false

    init(baseAsset: String = "joystick_base", stickAsset: String = "joystick_ball") {
        baseNode = SKSpriteNode(imageNamed: baseAsset)
        baseNode.name = "floatingJoystickBase"
        baseNode.size = CGSize(width: radius * 1.8, height: radius * 1.8)
        baseNode.zPosition = 1
        baseNode.alpha = 0 

        stickNode = SKSpriteNode(imageNamed: stickAsset)
        stickNode.name = "floatingJoystickStick"
        stickNode.size = CGSize(width: radius, height: radius)
        stickNode.zPosition = 2
        stickNode.alpha = 0
        
        super.init()

        addChild(baseNode)
        addChild(stickNode)

        zPosition = 1001
        
        isUserInteractionEnabled = false 
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Touch Injection

    func injectTouchBegan(_ touch: UITouch, in node: SKNode) {
        guard trackingTouch == nil else { return }
        
        
        let location = touch.location(in: self)
        trackingTouch = touch
        isTouching = true
        
        
        baseNode.position = location
        stickNode.position = location
        
        // Animação suave para aparecer
        baseNode.removeAllActions()
        stickNode.removeAllActions()
        baseNode.run(.fadeAlpha(to: 1.0, duration: 0.1))
        stickNode.run(.fadeAlpha(to: 1.0, duration: 0.1))
        
        updateStickPosition(with: location)
    }

    func injectTouchesMoved(_ touches: Set<UITouch>, in node: SKNode) {
        guard isTouching, let touch = trackingTouch, touches.contains(touch) else { return }
        updateStickPosition(with: touch.location(in: self))
    }

    func injectTouchesEnded(_ touches: Set<UITouch>, in node: SKNode) {
        if let touch = trackingTouch, touches.contains(touch) {
            resetJoystick()
        }
    }

    // MARK: - Private Logic

    private func updateStickPosition(with location: CGPoint) {
        // Calcula o movimento sempre em relação à base estática ancorada
        let dx = location.x - baseNode.position.x
        let dy = location.y - baseNode.position.y
        let distance = hypot(dx, dy)

        if distance <= radius {
            stickNode.position = location
            velocity = CGPoint(x: dx / radius, y: dy / radius)
        } else {
            let angle = atan2(dy, dx)
            stickNode.position = CGPoint(
                x: baseNode.position.x + cos(angle) * radius,
                y: baseNode.position.y + sin(angle) * radius
            )
            velocity = CGPoint(x: cos(angle), y: sin(angle))
        }

        // Normalização
        let magnitude = hypot(velocity.x, velocity.y)
        if magnitude > 0 {
            velocity.x /= magnitude
            velocity.y /= magnitude
        }
    }

    func resetJoystick() {
        trackingTouch = nil
        isTouching = false
        velocity = .zero
        
        // Animação suave para desaparecer
        baseNode.removeAllActions()
        stickNode.removeAllActions()
        baseNode.run(.fadeAlpha(to: 0, duration: 0.15))
        stickNode.run(.fadeAlpha(to: 0, duration: 0.15))
    }
}
