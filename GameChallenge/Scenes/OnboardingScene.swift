//
//  OnboardingScene.swift
//  GameChallenge
//
//  Created by Bernardo Garcia Fensterseifer on 23/03/26.
//

import SpriteKit
import AVFoundation

class OnboardingScene: SKScene {
    
    var onFinished: (() -> Void)?

    // ── Safe Area Padding ─────────────────────────────────────────────
    private var safeAreaLeft: CGFloat = 0
    private var safeAreaRight: CGFloat = 0
    
    private var typingIndex = 0
    private var typingText = ""

    override init() {
        super.init(size: UIScreen.main.bounds.size)
        scaleMode = .aspectFill
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private struct OnboardingPage {
        let backgroundAsset: String
        let text: String
    }

    private let pages: [OnboardingPage] = [
        OnboardingPage(backgroundAsset: "bg1", text: NSLocalizedString("onboarding1", comment: "")),
        OnboardingPage(backgroundAsset: "bg2", text: NSLocalizedString("onboarding2", comment: "")),
        OnboardingPage(backgroundAsset: "bg3", text: NSLocalizedString("onboarding3", comment: ""))
    ]

    private var currentPageIndex = 0
    private var isTyping         = false
    private let contentNode      = SKNode()
    private var textLabel:       SKLabelNode?
    private var tapHintLabel:    SKLabelNode?

    private let fontName         = "PressStart2P-Regular"
    private let fontSize:        CGFloat = 11
    private let lineSpacing:     CGFloat = 8
    private let textPadding:     CGFloat = 24
    private let typingInterval:  TimeInterval = 0.05
    private var typingAudioPlayer: AVAudioPlayer?

    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(contentNode)
        
        // ── Captura o recuo da Dynamic Island / Safe Area ───────────────
        if let window = view.window {
            safeAreaLeft = window.safeAreaInsets.left
            safeAreaRight = window.safeAreaInsets.right
        }
        
        setupTypingSound()
        showPage(index: 0, animated: false)
    }

    private func setupTypingSound() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: .mixWithOthers)
        try? AVAudioSession.sharedInstance().setActive(true)
        if let url = Bundle.main.url(forResource: "typing", withExtension: "wav") {
            typingAudioPlayer = try? AVAudioPlayer(contentsOf: url)
            typingAudioPlayer?.volume = 0.12
            typingAudioPlayer?.prepareToPlay()
        }
    }

    private func showPage(index: Int, animated: Bool) {
        guard index < pages.count else { goToGame(); return }
        currentPageIndex = index
        let page = pages[index]

        if animated {
            contentNode.run(.fadeOut(withDuration: 0.4)) { [weak self] in
                self?.buildPage(page)
                self?.contentNode.run(.fadeIn(withDuration: 0.4)) { self?.startTyping() }
            }
        } else {
            buildPage(page)
            startTyping()
        }
    }

    private func buildPage(_ page: OnboardingPage) {
        contentNode.removeAllChildren()

        let bg = SKSpriteNode(imageNamed: page.backgroundAsset)
        bg.size = size
        bg.zPosition = 0
        contentNode.addChild(bg)

        // ── Cálculo da largura respeitando Safe Area ────────────────────
        // Adicionamos o safeAreaLeft e safeAreaRight para garantir que a caixa encolha nos iPhones com Notch
        let effectivePadding = textPadding + max(safeAreaLeft, safeAreaRight)
        let boxWidth = size.width - (effectivePadding * 2)

        let label = SKLabelNode(fontNamed: fontName)
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = boxWidth - (textPadding * 2)
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .top
        label.zPosition = 2
        textLabel = label

        let fullLabel = SKLabelNode(fontNamed: fontName)
        fullLabel.numberOfLines = 0
        fullLabel.preferredMaxLayoutWidth = label.preferredMaxLayoutWidth
        applyAttributedText(page.text, to: fullLabel)
        
        let boxHeight = fullLabel.frame.height + (textPadding * 2.5)
        let boxY = -size.height / 2 + textPadding + boxHeight / 2

        let textBox = SKSpriteNode(imageNamed: "textbox_bg")
        textBox.size = CGSize(width: boxWidth, height: boxHeight)
        
        // Se houver Notch/Dynamic Island no lado esquerdo, empurramos a caixa para a direita
        let xOffset = (safeAreaLeft - safeAreaRight) / 2
        textBox.position = CGPoint(x: xOffset, y: boxY)
        textBox.zPosition = 1
        contentNode.addChild(textBox)

        label.position = CGPoint(x: -boxWidth / 2 + textPadding, y: boxHeight / 2 - textPadding)
        textBox.addChild(label)

        let hint = SKLabelNode(fontNamed: fontName)
        hint.fontSize = 7
        hint.fontColor = UIColor(white: 1, alpha: 0.5)
        hint.text = NSLocalizedString("continue_label", comment: "")
        hint.horizontalAlignmentMode = .right
        hint.position = CGPoint(x: boxWidth / 2 - textPadding, y: -boxHeight / 2 + 12)
        hint.zPosition = 2
        hint.alpha = 0
        textBox.addChild(hint)
        tapHintLabel = hint
    }

    private func applyAttributedText(_ text: String, to label: SKLabelNode) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = .left
        paragraphStyle.lineBreakMode = .byWordWrapping

        let font = UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraphStyle
        ]
        label.attributedText = NSAttributedString(string: text, attributes: attributes)
    }

    private func startTyping() {
        guard let label = textLabel else { return }
        
        let fullText = pages[currentPageIndex].text
        isTyping = true
        
        label.attributedText = nil
        label.text = ""
        
        var charIndex = 0
        let chars = Array(fullText)
        
        let typeStep = SKAction.run { [weak self] in
            guard let self = self else { return }
            
            let current = String(chars[0...charIndex])
            self.applyAttributedText(current, to: label)
            
            let char = chars[charIndex]
            if char != " " && char != "\n" {
                self.typingAudioPlayer?.stop()
                self.typingAudioPlayer?.currentTime = 0
                self.typingAudioPlayer?.play()
            }
            
            charIndex += 1
        }
        
        let wait       = SKAction.wait(forDuration: typingInterval)
        let typeLoop   = SKAction.repeat(SKAction.sequence([typeStep, wait]), count: chars.count)
        let onFinished = SKAction.run { [weak self] in
            self?.typingFinished()
        }
        
        // Chave idêntica à do Chat para o removeAction funcionar igual
        label.removeAction(forKey: "typing")
        label.run(SKAction.sequence([typeLoop, onFinished]), withKey: "typing")
    }
    
    private func typingFinished() {
        // Garante que o texto completo aparece (cobre edge case de skip)
        applyAttributedText(pages[currentPageIndex].text, to: textLabel!)
        isTyping = false
        showTapHint()
    }

    private func skipTyping() {
        textLabel?.removeAction(forKey: "typing")
        typingFinished()
    }

    private func showTapHint() {
        tapHintLabel?.run(.repeatForever(.sequence([.fadeAlpha(to: 0.1, duration: 0.6), .fadeAlpha(to: 0.7, duration: 0.6)])))
    }

    private func advance() {
        if isTyping {
            skipTyping()
        } else {
            let next = currentPageIndex + 1
            if next < pages.count {
                showPage(index: next, animated: true)
            } else {
                goToGame()
            }
        }
    }

    private func goToGame() {
        self.isUserInteractionEnabled = false
        let blackOverlay = SKSpriteNode(color: .black, size: self.size)
        blackOverlay.zPosition = 100
        blackOverlay.alpha = 0
        addChild(blackOverlay)
        blackOverlay.run(.fadeIn(withDuration: 1.2)) { [weak self] in self?.onFinished?() }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { advance() }
}
