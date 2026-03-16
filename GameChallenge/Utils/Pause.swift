//
//  Pause.swift
//  SSC1
//
//  Created by Vicenzo Másera on 20/01/26.
//

import Foundation
import SpriteKit

class Pause: SKNode {
    
    var background: SKSpriteNode
    
    var resumeLabel: SKLabelNode
    var resumeButton: SKSpriteNode
    
    var exitLabel: SKLabelNode
    var exitButton: SKSpriteNode
    
    var onEndedPauseAction: () -> Void = { }
    
    init(size: CGSize) {
        
        background = SKSpriteNode(color: .black, size: size)
        background.alpha = 0.6
        background.zPosition = 0
        
        let resumeTexture = SKTexture(imageNamed: "playButton")
        resumeTexture.filteringMode = .nearest
        resumeButton = SKSpriteNode(texture: resumeTexture)
        resumeButton.scale(to: CGSize(width: size.width * 0.25, height: size.width * 0.25 * 0.5))
        resumeButton.position = CGPoint(x: 0, y: size.height*0.1)
        resumeButton.zPosition = 0
        resumeButton.name = "playButton"
        
        resumeLabel = SKLabelNode(text: "Resume")
        resumeLabel.fontSize = 30
        resumeLabel.fontColor = .white
        resumeLabel.fontName = AppManager.shared.appFont
        resumeLabel.position = CGPoint(x: 0, y: resumeButton.position.y + 100)
        resumeLabel.name = "resumeLabel"
        
        let exitTexture = SKTexture(imageNamed: "backButton")
        exitTexture.filteringMode = .nearest
        exitButton = SKSpriteNode(texture: exitTexture)
        exitButton.scale(to: CGSize(width: size.width*0.25*0.5, height: size.width*0.25*0.5))
        exitButton.position = CGPoint(x: 0, y: -size.height*0.1)
        exitButton.zPosition = 0
        exitButton.name = "backButton"
        
        exitLabel = SKLabelNode(text: "Exit")
        exitLabel.fontSize = 30
        exitLabel.fontColor = .white
        exitLabel.fontName = AppManager.shared.appFont
        exitLabel.position = CGPoint(x: 0, y: exitButton.position.y - 100)
        exitLabel.name = "exitLabel"
        
        super.init()
        
        addChild(background)
        
        addChild(resumeLabel)
        addChild(resumeButton)
        
        addChild(exitLabel)
        addChild(exitButton)
        
        
        self.alpha = 0
        self.isUserInteractionEnabled = false
        self.zPosition = 2000
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pauseGame() {
        self.alpha = 1
        self.isUserInteractionEnabled = true
        scene?.isPaused = true
        scene?.physicsWorld.speed = 0
        
    }
    
    func resumeGame() {
        self.alpha = 0
        self.isUserInteractionEnabled = false
        
        scene?.isPaused = false
        scene?.physicsWorld.speed = 1
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let node = atPoint(location)
            
            if node.name == "playButton" {
                SoundManager.shared.play(SoundManager.shared.button, on: node)
                resumeGame()
                onEndedPauseAction()
            }
            else if node.name == "backButton" {
                SoundManager.shared.play(SoundManager.shared.button, on: node)
                if let scene = self.scene?.view {
                    let menuScene = MenuScene(size: self.scene!.size)
                    menuScene.scaleMode = self.scene!.scaleMode
                    scene.presentScene(menuScene)
                }
            }
        }
    }
    
}
