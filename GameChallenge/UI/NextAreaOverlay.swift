//
//  NextAreaOverlay.swift
//  SSC2
//
//  Created by Vicenzo Másera on 13/02/26.
//

import SpriteKit
import GameplayKit

class NextStepOnTutorialOverlay: SKNode {
    
    var background: SKSpriteNode
    var messageLabel: SKLabelNode
    var continueButton: SKSpriteNode
    
    var onDismiss: () -> Void = { }
    
    init(size: CGSize, text: String) {
        
        background = SKSpriteNode(color: .black, size: size)
        background.alpha = 0.8
        background.zPosition = 0
        
        messageLabel = SKLabelNode(text: text)
        messageLabel.fontName = AppManager.shared.secondaryFont
        messageLabel.fontSize = 30
        messageLabel.fontColor = .white
        messageLabel.numberOfLines = 0
        messageLabel.preferredMaxLayoutWidth = size.width * 0.8
        messageLabel.horizontalAlignmentMode = .center
        messageLabel.verticalAlignmentMode = .center
        messageLabel.position = CGPoint(x: 0, y: size.height * 0.1)
        messageLabel.zPosition = 1
        
        let continueTexture = SKTexture(imageNamed: "playButton")
        continueTexture.filteringMode = .nearest
        continueButton = SKSpriteNode(texture: continueTexture)
        let btnWidth = size.width * 0.25
        continueButton.size = CGSize(width: btnWidth, height: btnWidth * 0.5)
        continueButton.position = CGPoint(x: 0, y: -size.height * 0.2)
        continueButton.zPosition = 1
        continueButton.name = "continueButton"
        
        
        super.init()
        
        addChild(background)
        addChild(messageLabel)
        addChild(continueButton)
        
        self.alpha = 0
        self.isUserInteractionEnabled = false
        self.zPosition = 2000
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func dismiss() {
        self.isUserInteractionEnabled = false
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        
        self.run(SKAction.sequence([fadeOut, remove])) {
            self.onDismiss()
        }
    }
    
    func start() {
        let wait = SKAction.wait(forDuration: 0.2)
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        
        let sequence = SKAction.sequence([wait, fadeIn])
        self.run(sequence) {
            self.isUserInteractionEnabled = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let hitNodes = nodes(at: location)
            
            for node in hitNodes {
                if node.name == "continueButton" {
                    vibrate(with: .light)
                    SoundManager.shared.play(SoundManager.shared.button, on: self)
                    
                    let scaleDown = SKAction.scale(to: 0.9, duration: 0.1)
                    let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
                    
                    continueButton.run(SKAction.sequence([scaleDown, scaleUp])) { [weak self] in
                        self?.dismiss()
                    }
                    
                    return
                }
            }
        }
    }
}
