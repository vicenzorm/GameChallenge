//
//  FinaleScene.swift
//  SSC2
//
//  Created by Vicenzo Másera on 09/02/26.
//
import SpriteKit
import Foundation

class MenuScene: SKScene {
    
    var background: SKSpriteNode!
    var titleLabel: SKLabelNode!
    
    var playButton: SKSpriteNode!
    
    override init(size: CGSize) {
        super.init(size: size)
        
        makeBackground(size: size)
        makeLabels(size: size)
        makeButtons(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        AdManager.shared.loadAd()
    }
    
    func makeBackground(size: CGSize) {
        
        let backgroundTexture = SKTexture(imageNamed: "menuBackground")
        backgroundTexture.filteringMode = .nearest
        background = SKSpriteNode(texture: backgroundTexture)
        background.size = size
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        background.name = "background"
        addChild(background)
    }
    
    func makeButtons(size: CGSize) {
        let buttonsWSize = size.width * 0.25
        let buttonsHSize = buttonsWSize * 0.5
        
        let playButtonTexture = SKTexture(imageNamed: "playButton")
        playButtonTexture.filteringMode = .nearest
        playButton = SKSpriteNode(texture: playButtonTexture)
        playButton.size = CGSize(width: buttonsWSize, height: buttonsHSize)
        playButton.position = CGPoint(x: size.width * 0.3, y: size.height * 0.15)
        playButton.zPosition = 1
        playButton.name = "playButton"
        addChild(playButton)
    }
    
    
    func makeLabels(size: CGSize) {
        titleLabel = SKLabelNode(text: "Dungeon Climber")
        titleLabel.fontName = AppManager.shared.appFont
        titleLabel.fontSize = AppManager.shared.fontSize(type: .subtitle, screenSize: size)
        titleLabel.fontColor = .black
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.verticalAlignmentMode = .top
        titleLabel.numberOfLines = 0
        titleLabel.preferredMaxLayoutWidth = size.width * 0.80
        titleLabel.position = CGPoint(x: size.width * 0.5, y: size.height * 0.95)
        titleLabel.zPosition = 1
        titleLabel.name = "titleLabel"
        addChild(titleLabel)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = self.atPoint(location)
            if let name = touchedNode.name {
                switch name {
                case "playButton":
                    
                    let gameScene = GameScene(size: self.size)
                    gameScene.scaleMode = self.scaleMode
                    self.run(specialSequence) {
                        self.view?.presentScene(gameScene)
                    }
                
                    
                    
                case "infoButton":
                    print("hahha")
                default:
                    break
                }
            }
        }
    }
}
