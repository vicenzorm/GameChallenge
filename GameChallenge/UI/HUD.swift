//
//  HUD.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 12/03/26.
//

// MARK: - HUD
// Landscape layout. All elements anchored to camera space.

import SpriteKit
import AVFoundation

class HUD: SKNode {
    
    private let waveLabel:      SKLabelNode
    private let buttonA: SKSpriteNode
    private let buttonB: SKSpriteNode
    private let buttonC: SKSpriteNode
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


//    private var continueButtonNode: SKShapeNode?
    
    private let waveProgressBg:   SKSpriteNode
    private let waveProgressFill: SKCropNode
    private let waveProgressMask: SKSpriteNode
    
    private let specialRingCrop: SKCropNode
    private let specialRingMask: SKSpriteNode
    
    private var backgroundVideoNode: SKVideoNode?
    private var videoPlayer: AVQueuePlayer?
    private var videoLooper: AVPlayerLooper?
    

    init(screenSize: CGSize) {
        self.screenSize = screenSize
        let hw = screenSize.width  / 2
        let hh = screenSize.height / 2
        
        // ── Character Image ────────────────────────────────────────
        let charImg = SKSpriteNode(imageNamed: "characterImage")
        charImg.zPosition = 100
        charImg.position  = CGPoint(x: -hw + 60, y: hh - 50)
        charImg.size      = CGSize(width: 65, height: 65)
        
        // ── Health bar (top-left) ──────────────────────────────────
        let barBg = SKSpriteNode(imageNamed: "healthBarBackground")
        barBg.size      = CGSize(width: 156, height: 22.7)
        barBg.position  = CGPoint(x: -hw + 160, y: hh - 35)
        barBg.zPosition = 99
        
        healthSprite.size = CGSize(width: 156, height: 22.7)
        let hMask = SKSpriteNode(color: .white, size: healthSprite.size)
        hMask.anchorPoint = CGPoint(x: 0, y: 0.5)
        hMask.position.x  = -healthSprite.size.width / 2
        let hCrop = SKCropNode()
        hCrop.addChild(healthSprite)
        hCrop.maskNode  = hMask
        hCrop.position  = CGPoint(x: -hw + 160, y: hh - 35)
        hCrop.zPosition = 100
        healthCrop = hCrop
        healthMask = hMask
        
        // ── Special bar (top-left, abaixo da health) ───────────────
        let specialBarBg = SKSpriteNode(imageNamed: "specialBarBackground")
        specialBarBg.size      = CGSize(width: 121.3, height: 13.5)
        specialBarBg.position  = CGPoint(x: -hw + 150, y: hh - 58)
        specialBarBg.zPosition = 99
        
        let specialSprite = SKSpriteNode(imageNamed: "specialBarFull")
        specialSprite.size = CGSize(width: 121.3, height: 13.5)
        let sMask = SKSpriteNode(color: .white, size: specialSprite.size)
        sMask.anchorPoint = CGPoint(x: 0, y: 0.5)
        sMask.position.x  = -specialSprite.size.width / 2
        let sCrop = SKCropNode()
        sCrop.addChild(specialSprite)
        sCrop.maskNode  = sMask
        sCrop.position  = CGPoint(x: -hw + 148, y: hh - 58)
        sCrop.zPosition = 100
        specialCrop = sCrop
        specialMask = sMask
        
        // ── Wave label (top-centre) ────────────────────────────────
        waveLabel          = SKLabelNode(text: "Floor 1")
        waveLabel.fontName = AppManager.shared.secondaryFont
        waveLabel.fontSize = 16
        waveLabel.fontColor = .white
        waveLabel.horizontalAlignmentMode = .center
        waveLabel.position  = CGPoint(x: 0, y: hh - 24)
        waveLabel.zPosition = 100
        
        // ── Wave progress bar (abaixo do waveLabel) ────────────────
        let progBarW: CGFloat = 130
        let progBarH: CGFloat = 8
        
        // Fundo usando o asset healthBarBackground como máscara visual
        let progBg = SKSpriteNode(imageNamed: "healthBarBackground")
        progBg.size      = CGSize(width: progBarW, height: progBarH)
        progBg.position  = CGPoint(x: 0, y: hh - 38)
        progBg.zPosition = 100
        
        // Sprite de preenchimento — usa waveBarFull quando cheia, cor amarela enquanto carrega
        let progSprite = SKSpriteNode(imageNamed: "waveBarFull")
        progSprite.size = CGSize(width: progBarW, height: progBarH)
        
        let progMask = SKSpriteNode(color: .white, size: CGSize(width: progBarW, height: progBarH))
        progMask.anchorPoint = CGPoint(x: 0, y: 0.5)
        progMask.position.x  = -progBarW / 2
        
        let progCrop = SKCropNode()
        progCrop.addChild(progSprite)
        progCrop.maskNode  = progMask
        progCrop.position  = CGPoint(x: 0, y: hh - 38)
        progCrop.zPosition = 101
        
        waveProgressBg   = progBg        // agora é SKSpriteNode — ajuste a declaração (veja abaixo)
        waveProgressFill = progCrop
        waveProgressMask = progMask
        
        // ── Countdown label ────────────────────────────────────────
        countdownLabel          = SKLabelNode(text: "")
        countdownLabel.fontName = AppManager.shared.secondaryFont
        countdownLabel.fontSize = 13
        countdownLabel.fontColor = UIColor(white: 0.7, alpha: 1)
        countdownLabel.horizontalAlignmentMode = .center
        countdownLabel.position  = CGPoint(x: 0, y: hh - 52)   // empurrado pra baixo da barra
        countdownLabel.zPosition = 100
        
        // ── Pause button (top-right) ───────────────────────────────
        pauseButton          = SKSpriteNode(imageNamed: "pauseButton")
        pauseButton.size     = CGSize(width: 45, height: 42)
        pauseButton.position = CGPoint(x: hw - 60, y: hh - 48)
        pauseButton.zPosition = 100
        pauseButton.name     = "pauseButton"
        
        // ── Button A — attack (bottom-right) ──────────────────────
        buttonA          = SKSpriteNode(imageNamed: "attack_button")
        buttonA.size     = CGSize(width: 80, height: 80)
        buttonA.position = CGPoint(x: hw - 154, y: -hh + 152)
        buttonA.zPosition = 100
        buttonA.name     = "buttonA"
        
        // ── Button B — special (bottom-right) ─────────────────────
        buttonB          = SKSpriteNode(imageNamed: "special_button_off")
        buttonB.size     = CGSize(width: 88, height: 88)
        buttonB.position = CGPoint(x: hw - 200, y: -hh + 80)
        buttonB.zPosition = 100
        buttonB.alpha    = 0.01   // começa desabilitado
        buttonB.name     = "buttonB"
        
        // ── Button c — Shuriken (bottom-right) ─────────────────────
        buttonC          = SKSpriteNode(imageNamed: "joystick_shuriken") // Reusando a imagem
        buttonC.size     = CGSize(width: 80, height: 80)
        buttonC.position = CGPoint(x: hw - 80, y: -hh + 80) // Posição do lado direito
        buttonC.zPosition = 100
        buttonC.name     = "buttonC"
        
        // ── Anel de carga do especial (atrás do botão B) ───────────
        let ringRadius: CGFloat = 32   // mesmo raio do botão (88/2)
        
        // Círculo preenchido azul — será revelado de baixo pra cima pela máscara
        let ringShape = SKShapeNode(circleOfRadius: ringRadius)
        ringShape.fillColor   = UIColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 1.0)
        ringShape.strokeColor = UIColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 0.9)
        //ringShape.lineWidth   = 2
        
        // Converte o shape para textura para poder usar dentro do SKCropNode
        let ringTexture = SKView().texture(from: ringShape, crop: CGRect(
            x: -ringRadius, y: -ringRadius,
            width: ringRadius * 2, height: ringRadius * 2
        ))!
        let ringSprite = SKSpriteNode(texture: ringTexture)
        ringSprite.size = CGSize(width: ringRadius * 2, height: ringRadius * 2)
        
        // Máscara cresce de baixo pra cima
        let ringMask = SKSpriteNode(color: .white,
                                    size: CGSize(width: ringRadius * 2, height: 0))
        ringMask.anchorPoint = CGPoint(x: 0.5, y: 0)
        ringMask.position    = CGPoint(x: 0, y: -ringRadius)
        
        let ringCrop = SKCropNode()
        ringCrop.addChild(ringSprite)
        ringCrop.maskNode  = ringMask
        ringCrop.position  = CGPoint(x: hw - 200 + 8, y: -hh + 80 - 8)  // ← deslocado para baixo-direita
        ringCrop.zPosition = -100
        specialRingCrop = ringCrop
        specialRingMask = ringMask
        
        // ── super.init ─────────────────────────────────────────────
        super.init()
        zPosition = 99
        
        addChild(charImg)
        addChild(barBg);         addChild(healthCrop)
        addChild(specialBarBg);  addChild(specialCrop)
        addChild(waveLabel);     addChild(countdownLabel)
        addChild(waveProgressBg); addChild(waveProgressFill)   // barra de progresso
        addChild(pauseButton)
        addChild(specialRingCrop)   // anel ANTES do botão B para ficar atrás
        addChild(buttonA);       addChild(buttonB)
        addChild(buttonC)
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
    
    // Barra de progresso da wave — chame do GameScene a cada inimigo morto
    // ratio: 0.0 (wave começou) → 1.0 (todos mortos)
    func updateWaveProgress(_ ratio: CGFloat) {
        let clamped = Swift.max(0, Swift.min(1, ratio))
        waveProgressMask.xScale = clamped
        
        // Quando completa, mostra o asset waveBarFull; senão, cor amarela
        if let fill = waveProgressFill.children.first as? SKSpriteNode {
            if clamped >= 1.0 {
                fill.texture          = SKTexture(imageNamed: "waveBarFull")
                fill.color            = .clear
                fill.colorBlendFactor = 0
            } else {
                fill.texture          = SKTexture(imageNamed: "waveBarFull")
                fill.color            = UIColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1)
                fill.colorBlendFactor = 1.0   // ← tinge de amarelo enquanto não está cheia
            }
        }
    }
    
    private func setupVideoBackground(videoName: String, rootNode: SKNode, size: CGSize) {
        guard let videoURL = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
            print("⚠️ Erro: Não foi possível carregar \(videoName).mp4")
            return
        }
        
        let playerItem = AVPlayerItem(url: videoURL)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        
        videoLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        videoPlayer = queuePlayer
        
        let videoNode = SKVideoNode(avPlayer: queuePlayer)
        videoNode.size = size
        videoNode.zPosition = 0
        
        backgroundVideoNode = videoNode
        rootNode.addChild(videoNode)
        
        videoNode.play()
    }
    
    private func stopVideoBackground() {
        backgroundVideoNode?.pause()
        videoLooper?.disableLooping()
        videoPlayer?.removeAllItems()
        
        backgroundVideoNode?.removeFromParent()
        
        backgroundVideoNode = nil
        videoPlayer = nil
        videoLooper = nil
    }
    
    // Sobrescreva updateSpecial para também atualizar o anel:
    func updateSpecial(killStreak: Int, isReady: Bool) {
        let ratio = CGFloat(Swift.min(killStreak, PlayerComponent.weakKillsNeeded))
        / CGFloat(PlayerComponent.weakKillsNeeded)
        specialMask.xScale = Swift.max(0, Swift.min(1, ratio))
        
        // Anel cresce de baixo pra cima
        let ringH = specialRingMask.size.width * Swift.max(0, Swift.min(1, ratio))
        specialRingMask.size = CGSize(width: specialRingMask.size.width, height: ringH)
        
        // Textura e opacidade do botão B — tudo aqui, nunca em outro lugar
        buttonB.texture = SKTexture(imageNamed: isReady ? "special_button_on" : "special_button_off")
        buttonB.alpha   = isReady ? 1.0 : 0.5
        
        if isReady {
            specialRingMask.size = CGSize(width: specialRingMask.size.width,
                                          height: specialRingMask.size.width)
            if specialRingCrop.action(forKey: "pulse") == nil {
                specialRingCrop.run(.repeatForever(.sequence([
                    .fadeAlpha(to: 0.3, duration: 0.35),
                    .fadeAlpha(to: 0.9, duration: 0.35)
                ])), withKey: "pulse")
            }
            if specialCrop.action(forKey: "pulse") == nil {
                specialCrop.run(.repeatForever(.sequence([
                    .fadeAlpha(to: 0.55, duration: 0.35),
                    .fadeAlpha(to: 1.0,  duration: 0.35)
                ])), withKey: "pulse")
            }
        } else {
            specialRingCrop.removeAction(forKey: "pulse")
            specialRingCrop.alpha = 1.0
            specialCrop.removeAction(forKey: "pulse")
            specialCrop.alpha = 1.0
        }
    }
    
    func updateWave(_ wave: Int) {
        waveLabel.text = "Floor \(wave)"
        countdownLabel.text = ""
        waveLabel.run(.sequence([.scale(to: 1.4, duration: 0.12), .scale(to: 1.0, duration: 0.12)]))
        
        if wave == 2{
            GameCenterManager.shared.reportAchievement(id: "first_floor", percent: 100.0)
        }else if wave == 5{
            GameCenterManager.shared.reportAchievement(id: "fifth_floor", percent: 100.0)
        }else if wave == 10{
            GameCenterManager.shared.reportAchievement(id: "tenth_floor", percent: 100.0)
        }
    }
    
    func showCountdown(_ seconds: Int) {
        if seconds > 0 {
            countdownLabel.text = "Next floor in \(seconds)…"
        } else {
            countdownLabel.text = ""
        }
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
            stopVideoBackground()
            pauseOverlay?.removeFromParent()
            pauseOverlay = nil
        }
    }
    
    private func buildPauseOverlay() -> SKNode {
        let root = SKNode()
        root.zPosition = 200

        setupVideoBackground(videoName: "pause_video", rootNode: root, size: self.screenSize)

        let title = SKLabelNode(text: "Pause")
        title.fontName = "PressStart2P-Regular"
        title.fontSize = 22.36
        title.fontColor = .white
        title.horizontalAlignmentMode = .left
        title.position = CGPoint(x: -341.25, y: 83.5)
        title.zPosition = 1
        root.addChild(title)

        let title2 = SKLabelNode(text: waveLabel.text)
        title2.fontName = "PressStart2P-Regular"
        title2.fontSize = 67
        title2.fontColor = .white
        title2.position = CGPoint(x: -341.25, y: 0)
        title2.zPosition = 1
        title2.horizontalAlignmentMode = .left
        root.addChild(title2)

        let buttonSpacing: CGFloat = 16
        let buttonW: CGFloat = 200
        let leftAnchor: CGFloat = -341.25

        let resumeBtn = makeOverlayButton(
            text: "Resume",
            pos: CGPoint(x: leftAnchor + buttonW / 2, y: -53.75),
            name: "resumeButton"
        )
        let exitBtn = makeOverlayButton(
            text: "Exit",
            pos: CGPoint(x: leftAnchor + buttonW + buttonSpacing + buttonW / 2, y: -53.75),
            name: "menuFromPause"
        )
        root.addChild(resumeBtn)
        root.addChild(exitBtn)
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
    
//    func updateContinueCooldown() {
//        guard let label = continueLabel, let button = continueButtonNode else { return }
//
//        // Buscamos o ícone dentro do botão (ele tem o mesmo nome do botão)
//        let icon = button.childNode(withName: "//" + (button.name ?? "")) as? SKSpriteNode
//
//
//        
//        if AdManager.shared.canShowAd() {
//            return "Continue"
//        }
//        
//        let remaining = Int(AdManager.shared.remainingCooldown())
//        let minutes = remaining / 60
//        let seconds = remaining % 60
//        
//        return String(format: "Continue (%02d:%02d)", minutes, seconds)
//    }
    
    func updateContinueCooldown() {
        guard let label = continueLabel, let button = continueButtonNode else { return }
        
        
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
        let root = SKNode();
        root.alpha = 0
        root.zPosition = 200
        gameOverOverlay = root

        let backgroundTexture = SKTexture(imageNamed: "gameOverBackground")
        let bg = SKSpriteNode(texture: backgroundTexture)
        bg.zPosition = 0
        root.addChild(bg)

        let title = SKLabelNode(text: "Game Over")
        title.fontName = "PressStart2P-Regular"
        title.fontSize = 67
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: 33.5)
        title.zPosition = 1
        root.addChild(title)

        let canShow = AdManager.shared.canShowAd()
        
        // Passando o asset "AD" aqui
        let continueBtn = makeOverlayButton(
            text: "Continue",
            pos: CGPoint(x: -210, y: -50),
            name: canShow ? "continueButton" : "continueDisabled",
            iconAssetName: "AD"
        )
        
        continueButtonNode = continueBtn as? SKSpriteNode
        continueLabel = firstLabel(in: continueBtn)
        let continueIcon = firstIcon(in: continueBtn)

        if !canShow {
            // Aplica o cinza total que a gente configurou (Shader ou Alpha)
            continueButtonNode?.color = .gray
            continueButtonNode?.colorBlendFactor = 1
            
            continueLabel?.fontColor = .gray
            continueLabel?.alpha = 0.3
            
            continueIcon?.color = .gray
            continueIcon?.colorBlendFactor = 1.0
            continueIcon?.alpha = 0.3
        }
        
        root.addChild(continueBtn)
        
        root.addChild(makeOverlayButton(text: "Restart", pos: CGPoint(x: 0, y: -50), name: "restartButton"))
        root.addChild(makeOverlayButton(text: "Menu", pos: CGPoint(x: 210, y: -50), name: "menuFromGameOver"))
        
        addChild(root)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        root.run(fadeIn)
    }
    
    func hideGameOver() {
        gameOverOverlay?.removeFromParent()
        gameOverOverlay = nil
        continueButtonNode = nil
        continueLabel = nil
    }

    private func makeOverlayButton(text: String, pos: CGPoint, name: String, iconAssetName: String? = nil) -> SKNode {
        let backgroundTexture = SKTexture(imageNamed: "buttonBackground")
        let bg = SKSpriteNode(texture: backgroundTexture)
        
        // Padding mantido como você gostou
        bg.size = CGSize(width: 160 + 40, height: 40 + 10)
        bg.zPosition = 1
        bg.position = pos
        bg.name = name
        
        let container = SKNode()
        
        let lbl = SKLabelNode(text: text)
        lbl.name = name
        lbl.fontName = "PressStart2P-Regular"
        lbl.fontSize = 11.75
        lbl.fontColor = .white
        lbl.verticalAlignmentMode = .center
        lbl.horizontalAlignmentMode = .left
        
        if let assetName = iconAssetName {
            // --- MUDANÇA AQUI: Carrega o asset direto ---
            let icon = SKSpriteNode(imageNamed: assetName)
            icon.name = name
            
            // Ajuste o tamanho do ícone "AD" conforme necessário
            icon.size = CGSize(width: 25, height: 25)
            
            let spacing: CGFloat = 8
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
