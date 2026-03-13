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

    private let healthBarFill:  SKShapeNode
    private let coinLabel:      SKLabelNode
    private let waveLabel:      SKLabelNode
    private let specialBg:      SKShapeNode
    private let specialLabel:   SKLabelNode
    private let specialFill:    SKShapeNode
    private let buttonA:        SKShapeNode
    private let buttonB:        SKShapeNode
    private let pauseButton:    SKShapeNode
    private let countdownLabel: SKLabelNode

    // Overlay nodes (created on demand)
    private var pauseOverlay:   SKNode?
    private var gameOverOverlay: SKNode?

    private let barMaxW: CGFloat = 160
    private let screenSize: CGSize

    init(screenSize: CGSize) {
        self.screenSize = screenSize
        let hw = screenSize.width  / 2
        let hh = screenSize.height / 2

        // ── Health bar (top-left) ──────────────────────────────
        let barH: CGFloat = 14
        let barBg = SKShapeNode(rectOf: CGSize(width: 160, height: barH), cornerRadius: 3)
        barBg.fillColor   = UIColor(white: 0.2, alpha: 0.85)
        barBg.strokeColor = UIColor(white: 1, alpha: 0.35)
        barBg.lineWidth   = 1
        barBg.position    = CGPoint(x: -hw + 90, y: hh - 26)
        barBg.zPosition   = 100

        healthBarFill = SKShapeNode(rectOf: CGSize(width: 156, height: barH - 4), cornerRadius: 2)
        healthBarFill.fillColor   = .green
        healthBarFill.strokeColor = .clear
        healthBarFill.zPosition   = 1
        barBg.addChild(healthBarFill)

        let hpLbl = SKLabelNode(text: "HP")
        hpLbl.fontName = "AvenirNext-Bold"; hpLbl.fontSize = 9
        hpLbl.fontColor = .white; hpLbl.position = CGPoint(x: -90, y: -5)
        barBg.addChild(hpLbl)

        // ── Coin icon + label (below health bar) ───────────────
        let coinIcon = SKShapeNode(circleOfRadius: 7)
        coinIcon.fillColor = .yellow
        coinIcon.strokeColor = UIColor(red: 0.8, green: 0.6, blue: 0, alpha: 1)
        coinIcon.lineWidth = 1; coinIcon.position = CGPoint(x: -hw + 18, y: hh - 48)
        coinIcon.zPosition = 100

        coinLabel = SKLabelNode(text: "0")
        coinLabel.fontName = "AvenirNext-Bold"; coinLabel.fontSize = 14
        coinLabel.fontColor = .yellow
        coinLabel.horizontalAlignmentMode = .left
        coinLabel.position = CGPoint(x: -hw + 30, y: hh - 55); coinLabel.zPosition = 100

        // ── Wave label (top-centre) ────────────────────────────
        waveLabel = SKLabelNode(text: "Wave 1")
        waveLabel.fontName = "AvenirNext-Heavy"; waveLabel.fontSize = 16
        waveLabel.fontColor = .white
        waveLabel.horizontalAlignmentMode = .center
        waveLabel.position = CGPoint(x: 0, y: hh - 24); waveLabel.zPosition = 100

        // Countdown (shown between waves, same position)
        countdownLabel = SKLabelNode(text: "")
        countdownLabel.fontName = "AvenirNext-Heavy"; countdownLabel.fontSize = 13
        countdownLabel.fontColor = UIColor(white: 0.7, alpha: 1)
        countdownLabel.horizontalAlignmentMode = .center
        countdownLabel.position = CGPoint(x: 0, y: hh - 42); countdownLabel.zPosition = 100

        // ── Special bar (top-right) ────────────────────────────
        let specW: CGFloat = 88
        specialBg = SKShapeNode(rectOf: CGSize(width: specW, height: 22), cornerRadius: 5)
        specialBg.fillColor = UIColor(white: 0.15, alpha: 0.85)
        specialBg.strokeColor = .cyan; specialBg.lineWidth = 1
        specialBg.position = CGPoint(x: hw - specW/2 - 12, y: hh - 26); specialBg.zPosition = 100

        specialLabel = SKLabelNode(text: "SPEC")
        specialLabel.fontName = "AvenirNext-Bold"; specialLabel.fontSize = 10
        specialLabel.fontColor = .cyan
        specialLabel.verticalAlignmentMode = .center
        specialLabel.horizontalAlignmentMode = .center
        specialLabel.position = CGPoint(x: 0, y: 2)

        let specTrack = SKShapeNode(rectOf: CGSize(width: specW - 8, height: 5), cornerRadius: 2)
        specTrack.fillColor = UIColor(white: 0.3, alpha: 1)
        specTrack.strokeColor = .clear; specTrack.position = CGPoint(x: 0, y: -7)

        specialFill = SKShapeNode(rectOf: CGSize(width: specW - 8, height: 5), cornerRadius: 2)
        specialFill.fillColor = .cyan; specialFill.strokeColor = .clear
        specialFill.position = CGPoint(x: 0, y: -7); specialFill.xScale = 0

        // ── Pause button (top-centre-right) ───────────────────
        pauseButton = SKShapeNode(rectOf: CGSize(width: 36, height: 26), cornerRadius: 6)
        pauseButton.fillColor = UIColor(white: 0.2, alpha: 0.85)
        pauseButton.strokeColor = UIColor(white: 1, alpha: 0.4); pauseButton.lineWidth = 1
        pauseButton.position = CGPoint(x: hw - 130, y: hh - 26); pauseButton.zPosition = 100
        pauseButton.name = "pauseButton"
        let pauseIco = SKLabelNode(text: "⏸")
        pauseIco.fontSize = 14; pauseIco.verticalAlignmentMode = .center
        pauseIco.horizontalAlignmentMode = .center; pauseIco.name = "pauseButton"
        pauseButton.addChild(pauseIco)

        // ── Button A — attack (bottom-right) ──────────────────
        buttonA = SKShapeNode(circleOfRadius: 28)
        buttonA.fillColor = UIColor(red: 0.15, green: 0.6, blue: 0.15, alpha: 0.88)
        buttonA.strokeColor = .white; buttonA.lineWidth = 2
        buttonA.position = CGPoint(x: hw - 46, y: -hh + 52); buttonA.zPosition = 100
        buttonA.name = "buttonA"
        let aLbl = SKLabelNode(text: "A")
        aLbl.fontName = "AvenirNext-Heavy"; aLbl.fontSize = 22; aLbl.fontColor = .white
        aLbl.verticalAlignmentMode = .center; aLbl.horizontalAlignmentMode = .center
        aLbl.zPosition = 1; aLbl.name = "buttonA"
        buttonA.addChild(aLbl)

        // ── Button B — special (bottom-right) ─────────────────
        buttonB = SKShapeNode(circleOfRadius: 22)
        buttonB.fillColor = UIColor(red: 0.1, green: 0.2, blue: 0.7, alpha: 0.88)
        buttonB.strokeColor = .cyan; buttonB.lineWidth = 2
        buttonB.position = CGPoint(x: hw - 100, y: -hh + 42); buttonB.zPosition = 100
        buttonB.name = "buttonB"
        let bLbl = SKLabelNode(text: "B")
        bLbl.fontName = "AvenirNext-Heavy"; bLbl.fontSize = 17; bLbl.fontColor = .white
        bLbl.verticalAlignmentMode = .center; bLbl.horizontalAlignmentMode = .center
        bLbl.zPosition = 1; bLbl.name = "buttonB"
        buttonB.addChild(bLbl)

        super.init()
        zPosition = 99

        addChild(barBg)
        addChild(coinIcon); addChild(coinLabel)
        addChild(waveLabel); addChild(countdownLabel)
        addChild(specialBg)
        specialBg.addChild(specialLabel)
        specialBg.addChild(specTrack)
        specialBg.addChild(specialFill)
        addChild(pauseButton)
        addChild(buttonA); addChild(buttonB)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - Update

    func updateHealth(current: CGFloat, maxHP: CGFloat) {
        let ratio = maxHP > 0 ? (current / maxHP) : 0
        healthBarFill.xScale    = Swift.max(0, ratio)
        healthBarFill.position.x = -(barMaxW - 4) * (1 - ratio) / 2

        if ratio > 0.6      { healthBarFill.fillColor = .green }
        else if ratio > 0.3 { healthBarFill.fillColor = .yellow }
        else                { healthBarFill.fillColor = .red }
    }

    func updateCoins(_ coins: Int) { coinLabel.text = "\(coins)" }

    func updateWave(_ wave: Int) {
        waveLabel.text = "Wave \(wave)"
        countdownLabel.text = ""
        waveLabel.run(.sequence([.scale(to: 1.4, duration: 0.12), .scale(to: 1.0, duration: 0.12)]))
    }

    func showCountdown(_ seconds: Int) {
        if seconds > 0 {
            countdownLabel.text = "Next wave in \(seconds)…"
        } else {
            countdownLabel.text = ""
        }
    }

    func updateSpecial(killStreak: Int, isReady: Bool) {
        let ratio = CGFloat(Swift.min(killStreak, PlayerComponent.weakKillsNeeded))
                  / CGFloat(PlayerComponent.weakKillsNeeded)
        specialFill.xScale = Swift.max(0, Swift.min(1, ratio))

        if isReady {
            specialBg.strokeColor = .yellow; specialLabel.fontColor = .yellow
            specialLabel.text = "READY"
            if specialBg.action(forKey: "pulse") == nil {
                specialBg.run(.repeatForever(.sequence([
                    .fadeAlpha(to: 0.55, duration: 0.35),
                    .fadeAlpha(to: 1.0,  duration: 0.35)
                ])), withKey: "pulse")
            }
        } else {
            specialBg.strokeColor = .cyan; specialLabel.fontColor = .cyan
            specialLabel.text = "SPEC"
            specialBg.removeAction(forKey: "pulse"); specialBg.alpha = 1
        }
    }

    func setButtonBActive(_ active: Bool) {
        buttonB.fillColor = active
            ? UIColor(red: 0.0, green: 0.55, blue: 0.85, alpha: 0.95)
            : UIColor(red: 0.1, green: 0.2,  blue: 0.7,  alpha: 0.88)
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

        let bg = SKShapeNode(rectOf: screenSize)
        bg.fillColor = UIColor.black.withAlphaComponent(0.65)
        bg.strokeColor = .clear
        root.addChild(bg)

        let title = SKLabelNode(text: "PAUSED")
        title.fontName = "AvenirNext-Heavy"; title.fontSize = 36
        title.fontColor = .white; title.position = CGPoint(x: 0, y: 50)
        root.addChild(title)

        root.addChild(makeOverlayButton(
            text: "▶  RESUME",
            color: UIColor(red: 0.1, green: 0.55, blue: 0.1, alpha: 0.95),
            pos: CGPoint(x: 0, y: -10),
            name: "resumeButton"
        ))
        root.addChild(makeOverlayButton(
            text: "⬅  MENU",
            color: UIColor(red: 0.4, green: 0.1, blue: 0.1, alpha: 0.95),
            pos: CGPoint(x: 0, y: -70),
            name: "menuFromPause"
        ))
        return root
    }

    // MARK: - Game Over Overlay

    func showGameOver() {
        guard gameOverOverlay == nil else { return }
        let root = SKNode(); root.zPosition = 200
        gameOverOverlay = root

        let bg = SKShapeNode(rectOf: screenSize)
        bg.fillColor = UIColor.black.withAlphaComponent(0.75)
        bg.strokeColor = .clear; root.addChild(bg)

        let title = SKLabelNode(text: "GAME OVER")
        title.fontName = "AvenirNext-Heavy"; title.fontSize = 40
        title.fontColor = .red; title.position = CGPoint(x: 0, y: 55)
        root.addChild(title)

        root.addChild(makeOverlayButton(
            text: "↺  PLAY AGAIN",
            color: UIColor(red: 0.1, green: 0.5, blue: 0.1, alpha: 0.95),
            pos: CGPoint(x: 0, y: -5),
            name: "restartButton"
        ))
        root.addChild(makeOverlayButton(
            text: "⬅  MENU",
            color: UIColor(red: 0.3, green: 0.1, blue: 0.1, alpha: 0.95),
            pos: CGPoint(x: 0, y: -65),
            name: "menuFromGameOver"
        ))
        addChild(root)
    }

    private func makeOverlayButton(text: String, color: UIColor, pos: CGPoint, name: String) -> SKNode {
        let bg = SKShapeNode(rectOf: CGSize(width: 210, height: 48), cornerRadius: 12)
        bg.fillColor = color; bg.strokeColor = UIColor(white: 1, alpha: 0.5)
        bg.lineWidth = 1.5; bg.position = pos; bg.zPosition = 1; bg.name = name
        let lbl = SKLabelNode(text: text)
        lbl.fontName = "AvenirNext-Heavy"; lbl.fontSize = 18; lbl.fontColor = .white
        lbl.verticalAlignmentMode = .center; lbl.horizontalAlignmentMode = .center
        lbl.name = name
        bg.addChild(lbl)
        return bg
    }
}
