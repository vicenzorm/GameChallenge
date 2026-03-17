//
//  SettingsScene.swift
//  GameChallenge
//
//  Created by Vicenzo Másera on 17/03/26.
//

import SpriteKit
import Foundation

class SettingsScene: SKScene {
    
    var background: SKSpriteNode!
    
    var backButton: SKSpriteNode!
    
    var titleLabel: SKLabelNode!
    
    var musicSwitch: SKSpriteNode!
    var sFXSwitch: SKSpriteNode!
    var hapticsSwitch: SKSpriteNode!
    
    override init(size: CGSize) {
        super.init(size: size)
        
        makeBackground(size: size)
        makeButtons()
        makeLabels()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
    }
    
    func makeBackground(size: CGSize) {
        let backgroundTexture = SKTexture(imageNamed: "settingsBackground")
        backgroundTexture.filteringMode = .nearest
        background = SKSpriteNode(texture: backgroundTexture)
        background.size = size
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        background.name = "background"
        addChild(background)
    }
    
    func makeLabels() {
        titleLabel = SKLabelNode(text: "Settings")
        titleLabel.fontColor = .white
        titleLabel.fontSize = 67
        titleLabel.fontName = AppManager.shared.secondaryFont
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: 425, y: 270)
        addChild(titleLabel)
    }
    
    func makeButtons() {
        let musicSwitchBackground = AppManager.shared.soundEnabled ? "miniButtonBackground" : "miniButtonBackgroundDeactivated"
        let sFXSwitchBackground = AppManager.shared.sFXEnabled ? "miniButtonBackground" : "miniButtonBackgroundDeactivated"
        let hapticsSwitchBackground = AppManager.shared.hapticsEnabled ? "miniButtonBackground" : "miniButtonBackgroundDeactivated"
        
        musicSwitch = makeButton(textureIcon: "musicIcon", textureBackground: musicSwitchBackground, label: "Music", pos: CGPoint(x: 300, y: 135), buttonIconSize: 40)
        musicSwitch.name = "musicSwitch"
        addChild(musicSwitch)
        
        sFXSwitch = makeButton(textureIcon: "sFXIcon", textureBackground: sFXSwitchBackground, label: "Sound FX", pos: CGPoint(x: 432, y: 135), buttonIconSize: 40)
        sFXSwitch.name = "sFXSwitch"
        addChild(sFXSwitch)
                       
        hapticsSwitch = makeButton(textureIcon: "hapticsIcon", textureBackground: hapticsSwitchBackground, label: "Haptics", pos: CGPoint(x: 564, y: 135), buttonIconSize: 40)
        hapticsSwitch.name = "hapticsSwitch"
        addChild(hapticsSwitch)
                               
        backButton = makeButton(textureIcon: "backLabel", textureBackground: "miniButtonBackground", label: "", pos: CGPoint(x: 57, y: 346), buttonIconSize: 20)
        backButton.name = "backButton"
        backButton.size = CGSize(width: 50, height: 50)
        addChild(backButton)
    }
    
    private func makeButton(textureIcon: String, textureBackground: String, label: String, pos: CGPoint, buttonIconSize: Int) -> SKSpriteNode {
        let buttonsSize = CGSize(width: 108, height: 108)
        
        
        let buttonBackgroundTexture = SKTexture(imageNamed: textureBackground )
        let node = SKSpriteNode(texture: buttonBackgroundTexture)
        node.size = buttonsSize
        node.position = pos
        let label = SKLabelNode(text: label)
        label.fontColor = .white
        label.fontName = AppManager.shared.secondaryFont
        label.fontSize = 11
        label.position = CGPoint(x: 0, y: -70)
        
        let buttonIconTexture = SKTexture(imageNamed: textureIcon)
        buttonIconTexture.filteringMode = .nearest
        let buttonIcon = SKSpriteNode(texture: buttonIconTexture)
        buttonIcon.size = CGSize(width: buttonIconSize, height: buttonIconSize)
        buttonIcon.position = CGPoint.zero
        buttonIcon.zPosition = node.zPosition + 1
        
        node.addChild(buttonIcon)
        node.addChild(label)
        return node
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = self.atPoint(location)
            if let name = touchedNode.name ?? touchedNode.parent?.name {
                switch name {
                case "musicSwitch":
                    print("")
                    
                case "sFXSwitch":
                    print("Leaderboard")
                    
                case "hapticsSwitch":
                    print("Settings")
                    
                case "backButton":
                    print("hehehe")
                default:
                    break
                }
            }
        }
    }
}
