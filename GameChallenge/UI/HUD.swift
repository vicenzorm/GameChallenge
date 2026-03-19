//
//  HUD.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 12/03/26.
//

// MARK: - HUD
// Landscape layout. All elements anchored to camera space.

import SpriteKit

class HUD: SKNode {

    private let waveLabel:      SKLabelNode
    private let buttonA: SKSpriteNode
    private let buttonB: SKSpriteNode
    private let pauseButton:    SKSpriteNode
    private let countdownLabel: SKLabelNode
    
    
    private let healthSprite = SKSpriteNode(imageNamed: "healthBarFull")
    private let healthCrop: SKCropNode
    private let healthMask: SKSpriteNode
    
    private let specialCrop: SKCropNode
    private let specialMask: SKSpriteNode
    
    // Overlay nodes (created on demand)
    private var pauseOverlay:   SKNode?
    private var gameOverOverlay: SKNode?

    private let barMaxW: CGFloat = 160
    private let screenSize: CGSize
    
    private var continueLabel: SKLabelNode?
    private var continueButtonNode: SKShapeNode?

    init(screenSize: CGSize) {
        self.screenSize = screenSize
        let hw = screenSize.width  / 2
        let hh = screenSize.height / 2

        //Character Image
        
        let charImg = SKSpriteNode(imageNamed: "characterImage")
        charImg.zPosition = 100
        charImg.position = CGPoint(x: -hw + 60, y: hh - 50)
        charImg.size = CGSize(width: 65, height: 65)
        
        
        
        // ── Health bar (top-left) ──────────────────────────────
        let barBg = SKSpriteNode(imageNamed: "healthBarBackground")
        barBg.size = CGSize(width: 156, height: 22.7)
        barBg.position    = CGPoint(x: -hw + 160, y: hh - 35)
        barBg.zPosition   = 99

        
        healthSprite.size = CGSize(width: 156, height: 22.7)
        
        let hMask = SKSpriteNode(color: .white, size: healthSprite.size)
        hMask.anchorPoint = CGPoint(x: 0, y: 0.5)
        hMask.position.x  = -healthSprite.size.width / 2
        let hCrop = SKCropNode()
        hCrop.addChild(healthSprite)
        hCrop.maskNode = hMask
        hCrop.position = CGPoint(x: -hw + 160, y: hh - 35)
        hCrop.zPosition = 100
        
        healthCrop = hCrop
        healthMask = hMask
        
        
        // Special Bar
        let specialBarBg = SKSpriteNode(imageNamed: "specialBarBackground")
        specialBarBg.size = CGSize(width: 121.3, height: 13.5)
        specialBarBg.position    = CGPoint(x: -hw + 150, y: hh - 58)
        specialBarBg.zPosition   = 99
        
        let specialSprite = SKSpriteNode(imageNamed: "specialBarFull")
        specialSprite.size = CGSize(width: 121.3, height: 13.5)
        
        let sMask = SKSpriteNode(color: .white, size: specialSprite.size)
        sMask.anchorPoint = CGPoint(x: 0, y: 0.5)
        sMask.position.x = -specialSprite.size.width / 2
        let sCrop = SKCropNode()
        sCrop.addChild(specialSprite)
        sCrop.maskNode = sMask
        sCrop.position = CGPoint(x: -hw + 148, y: hh - 58)
        sCrop.zPosition = 100
        
        specialCrop = sCrop
        specialMask = sMask
        

        // ── Wave label (top-centre) ────────────────────────────
        waveLabel = SKLabelNode(text: "Floor 1")
        waveLabel.fontName = AppManager.shared.secondaryFont
        waveLabel.fontSize = 16
        waveLabel.fontColor = .white
        waveLabel.horizontalAlignmentMode = .center
        waveLabel.position = CGPoint(x: 0, y: hh - 24); waveLabel.zPosition = 100

        // Countdown (shown between waves, same position)
        countdownLabel = SKLabelNode(text: "")
        countdownLabel.fontName = AppManager.shared.secondaryFont; countdownLabel.fontSize = 13
        countdownLabel.fontColor = UIColor(white: 0.7, alpha: 1)
        countdownLabel.horizontalAlignmentMode = .center
        countdownLabel.position = CGPoint(x: 0, y: hh - 42); countdownLabel.zPosition = 100


        // ── Pause button (top-centre-right) ───────────────────
        pauseButton = SKSpriteNode(imageNamed: "pauseButton")
        pauseButton.size = CGSize(width: 45, height: 42)
        pauseButton.position = CGPoint(x: hw - 60, y: hh - 48); pauseButton.zPosition = 100
        pauseButton.name = "pauseButton"
        

        // ── Button A — attack (bottom-right) ──────────────────
        buttonA = SKSpriteNode(imageNamed: "attack_button")
        buttonA.size = CGSize(width: 80, height: 80)
        buttonA.position = CGPoint(x: hw - 154, y: -hh + 152); buttonA.zPosition = 100
        buttonA.name = "buttonA"

        // ── Button B — special (bottom-right) ─────────────────
        buttonB = SKSpriteNode(imageNamed: "special_button_off")
        buttonB.size = CGSize(width: 88, height: 88)
        buttonB.position = CGPoint(x: hw - 200, y: -hh + 80); buttonB.zPosition = 100
        buttonB.name = "buttonB"

        super.init()
        zPosition = 99

        addChild(charImg)
        addChild(barBg); addChild(healthCrop)
        addChild(specialBarBg)
        addChild(specialCrop)
        addChild(waveLabel); addChild(countdownLabel)
        addChild(pauseButton)
        addChild(buttonA); addChild(buttonB)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - Update

    func updateHealth(current: CGFloat, maxHP: CGFloat) {
        let ratio = maxHP > 0 ? (current / maxHP) : 0
        healthMask.xScale    = ratio

        healthSprite.colorBlendFactor = 1.0
        if ratio > 0.6      { healthSprite.color = .green }
        else if ratio > 0.3 { healthSprite.color = .yellow }
        else                { healthSprite.color = .red }
    }


    func updateWave(_ wave: Int) {
        waveLabel.text = "Floor \(wave)"
        countdownLabel.text = ""
        waveLabel.run(.sequence([.scale(to: 1.4, duration: 0.12), .scale(to: 1.0, duration: 0.12)]))
    }

    func showCountdown(_ seconds: Int) {
        if seconds > 0 {
            countdownLabel.text = "Next floor in \(seconds)…"
        } else {
            countdownLabel.text = ""
        }
    }

    func updateSpecial(killStreak: Int, isReady: Bool) {
        let ratio = CGFloat(Swift.min(killStreak, PlayerComponent.weakKillsNeeded))
                  / CGFloat(PlayerComponent.weakKillsNeeded)
        specialMask.xScale = Swift.max(0, Swift.min(1, ratio))

        if isReady {
            if specialCrop.action(forKey: "pulse") == nil {
                specialCrop.run(.repeatForever(.sequence([
                    .fadeAlpha(to: 0.55, duration: 0.35),
                    .fadeAlpha(to: 1.0,  duration: 0.35)
                ])), withKey: "pulse")
            }
        } else {
            specialCrop.removeAction(forKey: "pulse");
            specialCrop.alpha = 1
        }
    }

    func setButtonBActive(_ active: Bool) {
        buttonB.texture = SKTexture(imageNamed: active ? "special_button_on" : "special_button_off")
    }

    func flashButtonA() {
        buttonA.run(.sequence([.scale(to: 0.82, duration: 0.05), .scale(to: 1.0, duration: 0.1)]))
    }

    // MARK: - Pause Overlay

    func showPauseOverlay(_ show: Bool) {
        if show {
            guard pauseOverlay == nil else { return }
            let overlay = buildPauseOverlay()
            pauseOverlay = overlay
            addChild(overlay)
        } else {
            pauseOverlay?.removeFromParent()
            pauseOverlay = nil
        }
    }

    private func buildPauseOverlay() -> SKNode {
        let root = SKNode(); root.zPosition = 200

        let backgroundTexture = SKTexture(imageNamed: "pauseBackground")
        let bg = SKSpriteNode(texture: backgroundTexture)
        bg.zPosition = 0
        root.addChild(bg)

        let title = SKLabelNode(text: "Pause")
        title.fontName = "PressStart2P-Regular"; title.fontSize = 22.36
        title.fontColor = .white;
        title.position = CGPoint(x: -316.25, y: 83.5)
        title.zPosition = 1
        root.addChild(title)
        
        let title2 = SKLabelNode(text: waveLabel.text)
        title2.fontName = "PressStart2P-Regular"; title2.fontSize = 67
        title2.fontColor = .white;
        title2.position = CGPoint(x: -140.25, y: 0)
        title2.zPosition = 1
        root.addChild(title2)

        root.addChild(makeOverlayButton(
            text: "Resume",
            pos: CGPoint(x: -292.25, y: -43.75),
            name: "resumeButton"
        ))
        root.addChild(makeOverlayButton(
            text: "Exit",
            pos: CGPoint(x: -108.25, y: -43.75),
            name: "menuFromPause"
        ))
        return root
    }
    
    private func continueButtonText() -> String {

        if AdManager.shared.canShowAd() {
            return "Continue"
        }

        let remaining = Int(AdManager.shared.remainingCooldown())
        let minutes = remaining / 60
        let seconds = remaining % 60

        return String(format: "Continue (%02d:%02d)", minutes, seconds)
    }
    
    func updateContinueCooldown() {
        guard let label = continueLabel else { return }

        if AdManager.shared.canShowAd() {
            label.text = "Continue"
            continueButtonNode?.fillColor = UIColor(red: 0.2, green: 0.3, blue: 0.1, alpha: 0.95)
            continueButtonNode?.name = "continueButton"
            label.name = "continueButton"
        } else {
            label.text = continueButtonText()
            continueButtonNode?.fillColor = .darkGray
            continueButtonNode?.name = "continueDisabled"
            label.name = "continueDisabled"
        }
    }

    // MARK: - Game Over Overlay

    func showGameOver() {
        guard gameOverOverlay == nil else { return }
        let root = SKNode(); root.zPosition = 200
        gameOverOverlay = root

        let backgroundTexture = SKTexture(imageNamed: "gameOverBackground")
        let bg = SKSpriteNode(texture: backgroundTexture)
        bg.zPosition = 0
        root.addChild(bg)
        

        let title = SKLabelNode(text: "Game Over")
        title.fontName = "PressStart2P-Regular"; title.fontSize = 67
        title.fontColor = .white;
        title.position = CGPoint(x: 0, y: 33.5)
        title.zPosition = 1
        root.addChild(title)

        let canShow = AdManager.shared.canShowAd()

        root.addChild(makeOverlayButton(
            text: "Continue",
            pos: CGPoint(x: -183, y: -50),
            name: canShow ? "continueButton" : "continueDisabled"))
        
        root.addChild(makeOverlayButton(
            text: "Restart",
            pos: CGPoint(x: 0, y: -50),
            name: "restartButton"
        ))
        root.addChild(makeOverlayButton(
            text: "Menu",
            pos: CGPoint(x: 183, y: -50),
            name: "menuFromGameOver"
        ))
        addChild(root)
    }
    
    func hideGameOver() {
        gameOverOverlay?.removeFromParent()
        gameOverOverlay = nil
    }

    private func makeOverlayButton(text: String,  pos: CGPoint, name: String) -> SKNode {
        let backgroundTexture = SKTexture(imageNamed: "buttonBackground")
        let bg = SKSpriteNode(texture: backgroundTexture)
        bg.zPosition = 1
        bg.position = pos
        bg.name = name
        
        let lbl = SKLabelNode(text: text)
        lbl.name = name
        lbl.fontName = "PressStart2P-Regular"; lbl.fontSize = 11.75; lbl.fontColor = .white
        lbl.verticalAlignmentMode = .center; lbl.horizontalAlignmentMode = .center
        lbl.zPosition = 2
        bg.addChild(lbl)
        return bg
        
    }
}
