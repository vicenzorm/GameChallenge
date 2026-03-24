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
    private var continueButtonNode: SKSpriteNode?

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
        title.position = CGPoint(x: -286.25, y: 83.5)
        title.zPosition = 1
        root.addChild(title)
        
        let title2 = SKLabelNode(text: waveLabel.text)
        title2.fontName = "PressStart2P-Regular"; title2.fontSize = 67
        title2.fontColor = .white;
        title2.position = CGPoint(x: -341.25, y: 0)
        title2.zPosition = 1
        title2.horizontalAlignmentMode = .left
        root.addChild(title2)

        root.addChild(makeOverlayButton(
            text: "Resume",
            pos: CGPoint(x: -262.25, y: -53.75),
            name: "resumeButton"
        ))
        root.addChild(makeOverlayButton(
            text: "Exit",
            pos: CGPoint(x: -78.25, y: -53.75),
            name: "menuFromPause"
        ))
        return root
    }
    
    private func continueButtonText() -> String {

//        if AdManager.shared.canShowAd() {
//            return "Continue"
//        }
//
//        let remaining = Int(AdManager.shared.remainingCooldown())
//        let minutes = remaining / 60
//        let seconds = remaining % 60
//
//        return String(format: "Continue (%02d:%02d)", minutes, seconds)
        
        return "Continue"
    }
    
    func updateContinueCooldown() {
        guard let label = continueLabel, let button = continueButtonNode else { return }

        // Buscamos o ícone dentro do botão (ele tem o mesmo nome do botão)
        let icon = button.childNode(withName: "//" + (button.name ?? "")) as? SKSpriteNode

        if AdManager.shared.canShowAd() {
            // --- ESTADO ATIVO ---
            button.color = .white
            button.colorBlendFactor = 0
            
            label.fontColor = .white
            
            icon?.color = .white
            icon?.colorBlendFactor = 1.0
            
            button.name = "continueButton"
            label.name = "continueButton"
            icon?.name = "continueButton"
        } else {
            // --- ESTADO CINZA (COOLDOWN) ---
            button.color = .gray
            button.colorBlendFactor = 1
            
            label.fontColor = .gray
            label.alpha = 0.3
            
            icon?.color = .gray // Pintamos o ícone de cinza
            icon?.colorBlendFactor = 1.0
            
            button.name = "continueDisabled"
            label.name = "continueDisabled"
            icon?.name = "continueDisabled"
        }
    }

    // MARK: - Game Over Overlay

    func showGameOver() {
        guard gameOverOverlay == nil else { return }
        let root = SKNode(); root.zPosition = 200
        gameOverOverlay = root

        // Background do Overlay
        let backgroundTexture = SKTexture(imageNamed: "gameOverBackground")
        let bg = SKSpriteNode(texture: backgroundTexture)
        bg.zPosition = 0
        root.addChild(bg)

        // Título Game Over
        let title = SKLabelNode(text: "Game Over")
        title.fontName = "PressStart2P-Regular"
        title.fontSize = 67
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: 33.5)
        title.zPosition = 1
        root.addChild(title)

        let canShow = AdManager.shared.canShowAd()
        
        // 1. Criação do botão de Continue (com ícone play.display)
        let continueBtn = makeOverlayButton(
            text: "Continue",
            pos: CGPoint(x: -210, y: -50),
            name: canShow ? "continueButton" : "continueDisabled",
            symbolName: "play.display"
        )
        
        // Armazena a referência do fundo do botão
        continueButtonNode = continueBtn as? SKSpriteNode
        
        // Busca robusta do label/icone dentro da hierarquia do botão.
        continueLabel = firstLabel(in: continueBtn)
        let continueIcon = firstIcon(in: continueBtn)

        // 2. Aplicação do estado inicial de Cooldown (Todo Cinza)
        if !canShow {
            // Pinta o fundo de cinza
            continueButtonNode?.color = .gray
            continueButtonNode?.colorBlendFactor = 1
            
            // Pinta o texto de cinza claro
            continueLabel?.fontColor = .gray
            continueLabel?.alpha = 0.5
            
            // Pinta o ícone de cinza
            continueIcon?.color = .gray
            continueIcon?.colorBlendFactor = 1.0
        }
        
        root.addChild(continueBtn)
        
        // 3. Botão Restart (Centralizado)
        root.addChild(makeOverlayButton(
            text: "Restart",
            pos: CGPoint(x: 0, y: -50),
            name: "restartButton"
        ))
        
        // 4. Botão Menu (Direita)
        root.addChild(makeOverlayButton(
            text: "Menu",
            pos: CGPoint(x: 210, y: -50),
            name: "menuFromGameOver"
        ))
        
        addChild(root)
    }
    
    func hideGameOver() {
        gameOverOverlay?.removeFromParent()
        gameOverOverlay = nil
        continueButtonNode = nil
        continueLabel = nil
    }

    private func makeOverlayButton(text: String, pos: CGPoint, name: String, symbolName: String? = nil) -> SKNode {
        let backgroundTexture = SKTexture(imageNamed: "buttonBackground")
        let bg = SKSpriteNode(texture: backgroundTexture)
        
        // --- AJUSTE DE PADDING ---
        // Aumentamos o tamanho original em 40px na largura e 10px na altura
        bg.size = CGSize(width: 160 + 40, height: 40 + 10)
        bg.zPosition = 1
        bg.position = pos
        bg.name = name
        
        let container = SKNode() // Container para centralizar ícone + texto juntos
        
        let lbl = SKLabelNode(text: text)
        lbl.name = name
        lbl.fontName = "PressStart2P-Regular"
        lbl.fontSize = 11.75
        lbl.fontColor = .white
        lbl.verticalAlignmentMode = .center
        lbl.horizontalAlignmentMode = .left // Mudamos para left para alinhar com o ícone
        
        if let symbol = symbolName, let texture = createSymbolTexture(name: symbol, fontSize: 20, color: .white) {
            let icon = SKSpriteNode(texture: texture)
        
            icon.name = name
            let spacing: CGFloat = 8 // Espaço entre ícone e texto
            
            // Calculamos a largura total para centralizar o conjunto
            let totalWidth = icon.size.width + spacing + lbl.frame.width
            let startX = -totalWidth / 2
            
            icon.position = CGPoint(x: startX + icon.size.width / 2, y: 0)
            lbl.position = CGPoint(x: startX + icon.size.width + spacing, y: 0)
            
            container.addChild(icon)
        } else {
            lbl.horizontalAlignmentMode = .center
            lbl.position = .zero
        }
        
        container.addChild(lbl)
        container.zPosition = 2
        bg.addChild(container)
        
        return bg
    }
    
    private func createSymbolTexture(name: String, fontSize: CGFloat, color: UIColor) -> SKTexture? {
        let config = UIImage.SymbolConfiguration(pointSize: fontSize, weight: .bold)
        
        guard let image = UIImage(systemName: name, withConfiguration: config)?
            .withTintColor(color, renderingMode: .alwaysTemplate) else { return nil }

        // Renderiza manualmente já com a cor aplicada
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        color.set()
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let finalImage else { return nil }
        return SKTexture(image: finalImage)
    }
    
    private func firstLabel(in node: SKNode) -> SKLabelNode? {
        var result: SKLabelNode?
        node.enumerateChildNodes(withName: "//*") { child, stop in
            if let label = child as? SKLabelNode {
                result = label
                stop.pointee = true
            }
        }
        return result
    }
    
    private func firstIcon(in node: SKNode) -> SKSpriteNode? {
        var result: SKSpriteNode?
        node.enumerateChildNodes(withName: "//*") { child, stop in
            if let sprite = child as? SKSpriteNode, sprite.texture != nil {
                result = sprite
                stop.pointee = true
            }
        }
        return result
    }
}
