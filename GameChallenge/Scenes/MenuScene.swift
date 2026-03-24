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
    
    var zenithLabel: SKLabelNode!
    var secondaryLabel: SKLabelNode!
    
    // MARK: - Touch Tracking
    private var trackedTouch: UITouch?
    private var trackedButtonNode: SKNode?
    private var trackedButtonName: String?
    private var touchStartLocation: CGPoint = .zero
    private let cancelDragThreshold: CGFloat = 20
    
    override init(size: CGSize) {
        super.init(size: size)
        makeBackground(size: size)
        makeButtons(size: size)
        makeTitle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        AdManager.shared.loadAd()
        SoundManager.shared.playMusic(named: "menuSoundtrack.mp3")
    }
    
    // MARK: - Setup
    
    func makeTitle() {
        zenithLabel = SKLabelNode(text: "zenith")
        zenithLabel.fontName = AppManager.shared.appFont
        zenithLabel.fontSize = 220
        zenithLabel.color = .white
        zenithLabel.position = CGPoint(x: size.width/2 + 130, y: size.height/2 - 90)
        addChild(zenithLabel)
        
        secondaryLabel = SKLabelNode(text: "the endless tower")
        secondaryLabel.fontName = AppManager.shared.appFont
        secondaryLabel.fontSize = 37
        secondaryLabel.color = .white
        secondaryLabel.position = CGPoint(x: size.width/2 + 28, y: size.height/2 + 37)
        addChild(secondaryLabel)
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
        playLabel.position = .zero
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
        leaderboardLabel.position = .zero
        leaderboardLabel.zPosition = leaderboardButton.zPosition + 1
        leaderboardLabel.name = "leaderboardLabel"
        leaderboardButton.addChild(leaderboardLabel)
        
        let settingsButtonTexture = SKTexture(imageNamed: "miniButtonBackground")
        settingsButtonTexture.filteringMode = .nearest
        settingsButton = SKSpriteNode(texture: settingsButtonTexture)
        settingsButton.size = CGSize(width: 50, height: 50)
        settingsButton.position = CGPoint(x: 770 + settingsButton.size.width/2,
                                          y: 322 + settingsButton.size.height/2)
        settingsButton.zPosition = 1
        settingsButton.name = "settingsButton"
        addChild(settingsButton)
        
        let settingsLabelTexture = SKTexture(imageNamed: "settingsLabel")
        settingsLabelTexture.filteringMode = .nearest
        settingsLabel = SKSpriteNode(texture: settingsLabelTexture)
        settingsLabel.size = CGSize(width: 20, height: 20)
        settingsLabel.position = .zero
        settingsLabel.zPosition = 1
        settingsLabel.name = "settingsLabel"
        settingsButton.addChild(settingsLabel)
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard trackedTouch == nil, let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let touchedNode = self.atPoint(location)
        
        var current: SKNode? = touchedNode
        var resolvedName: String? = nil
        while let node = current {
            if let n = node.name, !n.isEmpty {
                resolvedName = n
                break
            }
            current = node.parent
        }
        guard let name = resolvedName else { return }
        
        let buttonNode = current ?? touchedNode
        
        switch name {
        case "playButton",       "playLabel",
             "leaderboardButton", "leaderboardLabel",
             "settingsButton",    "settingsLabel":
            trackedTouch       = touch
            trackedButtonNode  = buttonNode
            trackedButtonName  = name
            touchStartLocation = location
            buttonNode.removeAction(forKey: "springTap")
            buttonNode.run(.scale(to: 0.82, duration: 0.08), withKey: "springTap")
            SoundManager.shared.play(SoundManager.shared.button, on: touchedNode)
            vibrate(with: .light)
        default:
            break
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let tracked = trackedTouch, touches.contains(tracked) else { return }
        
        let location = tracked.location(in: self)
        let dx = abs(location.x - touchStartLocation.x)
        let dy = abs(location.y - touchStartLocation.y)
        
        if dx > cancelDragThreshold || dy > cancelDragThreshold {
            cancelTrackedButton()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let tracked = trackedTouch, touches.contains(tracked) else { return }
        defer { clearTrackedButton() }
        
        guard let name       = trackedButtonName,
              let buttonNode = trackedButtonNode else { return }
        
        buttonNode.removeAction(forKey: "springTap")
        let bounce = SKAction.scale(to: 1.12, duration: 0.10)
        bounce.timingMode = .easeOut
        let settle = SKAction.scale(to: 1.0, duration: 0.10)
        settle.timingMode = .easeInEaseOut
        buttonNode.run(.sequence([bounce, settle]), withKey: "springTap")
        
        switch name {
        case "playButton", "playLabel":
            let gameScene = GameScene(size: self.size)
            gameScene.scaleMode = self.scaleMode
            self.run(specialSequence) {
                self.view?.presentScene(gameScene)
            }
            
        case "leaderboardButton", "leaderboardLabel":
            GameCenterManager.shared.showLeaderboard(
                from: self.view?.window?.rootViewController)
            
        case "settingsButton", "settingsLabel":
            let settingsScene = SettingsScene(size: self.size)
            settingsScene.scaleMode = self.scaleMode
            self.view?.presentScene(settingsScene,
                transition: .moveIn(with: .right, duration: 0.5))
            
        default:
            break
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let tracked = trackedTouch, touches.contains(tracked) else { return }
        cancelTrackedButton()
    }
    
    // MARK: - Helpers
    
    private func cancelTrackedButton() {
        trackedButtonNode?.removeAction(forKey: "springTap")
        let restore = SKAction.scale(to: 1.0, duration: 0.12)
        restore.timingMode = .easeOut
        trackedButtonNode?.run(restore, withKey: "springTap")
        clearTrackedButton()
    }
    
    private func clearTrackedButton() {
        trackedTouch      = nil
        trackedButtonNode = nil
        trackedButtonName = nil
    }
}
