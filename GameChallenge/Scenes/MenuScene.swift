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
    
    var playButton: SKSpriteNode!
    var playLabel: SKLabelNode!
    
    var leaderboardButton: SKSpriteNode!
    var leaderboardLabel: SKLabelNode!
    
    var settingsButton: SKSpriteNode!
    var settingsLabel: SKSpriteNode!
    
    override init(size: CGSize) {
        super.init(size: size)
        
        makeBackground(size: size)
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
        let buttonsWSize = 160
        let buttonsHSize = 55
        
        let playButtonTexture = SKTexture(imageNamed: "buttonBackground")
        playButtonTexture.filteringMode = .nearest
        playButton = SKSpriteNode(texture: playButtonTexture)
        playButton.size = CGSize(width: buttonsWSize, height: buttonsHSize)
        playButton.position = CGPoint(x: 387 + buttonsWSize/2, y: 70 + buttonsHSize/2)
        playButton.zPosition = 1
        playButton.name = "playButton"
        addChild(playButton)
        
        playLabel = SKLabelNode(text: "Start")
        playLabel.fontName = AppManager.shared.secondaryFont
        playLabel.fontSize = 18
        playLabel.fontColor = .white
        playLabel.horizontalAlignmentMode = .center
        playLabel.verticalAlignmentMode = .center
        playLabel.position = CGPoint.zero
        playLabel.zPosition = playButton.zPosition + 1
        playLabel.name = "playLabel"
        playButton.addChild(playLabel)
        
        let leaderboardButtonTexture = SKTexture(imageNamed: "buttonBackground")
        leaderboardButtonTexture.filteringMode = .nearest
        leaderboardButton = SKSpriteNode(texture: leaderboardButtonTexture)
        leaderboardButton.size = CGSize(width: buttonsWSize, height: buttonsHSize)
        leaderboardButton.position = CGPoint(x: 571 + buttonsWSize/2, y: 70 + buttonsHSize/2)
        leaderboardButton.zPosition = 1
        leaderboardButton.name = "leaderboardButton"
        addChild(leaderboardButton)
        
        leaderboardLabel = SKLabelNode(text: "Leaderboard")
        leaderboardLabel.fontName = AppManager.shared.secondaryFont
        leaderboardLabel.fontSize = 11
        leaderboardLabel.fontColor = .white
        leaderboardLabel.horizontalAlignmentMode = .center
        leaderboardLabel.verticalAlignmentMode = .center
        leaderboardLabel.position = CGPoint.zero
        leaderboardLabel.zPosition = leaderboardButton.zPosition + 1
        leaderboardLabel.name = "leaderboardLabel"
        leaderboardButton.addChild(leaderboardLabel)
        
        let settingsButtonTexture = SKTexture(imageNamed: "miniButtonBackground")
        settingsButtonTexture.filteringMode = .nearest
        settingsButton = SKSpriteNode(texture: settingsButtonTexture)
        settingsButton.size = CGSize(width: 50, height: 50)
        settingsButton.position = CGPoint(x: 770 + settingsButton.size.width/2, y: 322 + settingsButton.size.height/2)
        settingsButton.zPosition = 1
        settingsButton.name = "settingsButton"
        addChild(settingsButton)
        
        let settingsLabelTexture = SKTexture(imageNamed: "settingsLabel")
        settingsLabelTexture.filteringMode = .nearest
        settingsLabel = SKSpriteNode(texture: settingsLabelTexture)
        settingsLabel.size = CGSize(width: 20, height: 20)
        settingsLabel.position = CGPoint.zero
        settingsLabel.zPosition = 1
        settingsLabel.name = "settingsLabel"
        settingsButton.addChild(settingsLabel)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = self.atPoint(location)
            if let name = touchedNode.name {
                switch name {
                case "playButton", "playLabel":
                    let gameScene = GameScene(size: self.size)
                    gameScene.scaleMode = self.scaleMode
                    self.run(specialSequence) {
                        self.view?.presentScene(gameScene)
                    }
    
                case "leaderboardButton", "leaderboardLabel":
                    print("Leaderboard")
                    
                case "settingsButton", "settingsLabel":
                    print("Settings")
                    
                default:
                    break
                }
            }
        }
    }
}
