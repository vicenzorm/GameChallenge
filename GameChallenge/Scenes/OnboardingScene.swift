//
//  OnboardingScene.swift
//  GameChallenge
//
//  Created by Bernardo Garcia Fensterseifer on 23/03/26.
//

import SpriteKit
import AVFoundation

class OnboardingScene: SKScene {
    
    // ── Callback para avisar o SwiftUI que terminou ───────────────────
    var onFinished: (() -> Void)?

    override init() {
        super.init(size: UIScreen.main.bounds.size)
        scaleMode = .aspectFill
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // ── Conteúdo das telas ────────────────────────────────────────────
    private struct OnboardingPage {
        let backgroundAsset: String
        let text: String
    }

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            backgroundAsset: "bg1",
            text: "The Tower was always there. A vast anomaly of dark stone that splits the skies, feared and shunned by all. Legends say no one has ever returned from its gates. But now, the structure has awakened and is expanding, draining the land of life and drying our world."
        ),
        OnboardingPage(
            backgroundAsset: "bg2",
            text: "You are not an adventurer seeking glory, and there are no treasures waiting at the top. You carry a burden. Wielding an ancient sword forged from the very core of the Tower, you are the only one capable of wounding this structure from within."
        ),
        OnboardingPage(
            backgroundAsset: "bg3",
            text: "As you cross the gates, the Tower will know you are there. It is a living, reactive organism that will create defenses in real time to crush you. The higher you climb, the more brutal the response will be. Wield your blade and survive. The ascent begins now."
        )
    ]

    // ── Estado ────────────────────────────────────────────────────────
    private var currentPageIndex = 0
    private var isTyping         = false

    // ── Nodes ─────────────────────────────────────────────────────────
    private let contentNode      = SKNode()
    private var backgroundNode:  SKSpriteNode?
    private var textBoxNode:     SKSpriteNode?
    private var textLabel:       SKLabelNode?
    private var tapHintLabel:    SKLabelNode?

    // ── Configurações ─────────────────────────────────────────────────
    private let fontName         = "PressStart2P-Regular"
    private let fontSize:        CGFloat = 11
    private let lineSpacing:     CGFloat = 8
    private let textPadding:     CGFloat = 24
    private let typingInterval:  TimeInterval = 0.05 // Levemente mais lento para legibilidade
    
    private var typingAudioPlayer: AVAudioPlayer?

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(contentNode)
        
        setupTypingSound()
        showPage(index: 0, animated: false)
    }

    // MARK: - Configuração de Som

    private func setupTypingSound() {
        // Garante que o áudio não tenha atraso e misture com outros sons
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: .mixWithOthers)
        try? AVAudioSession.sharedInstance().setActive(true)

        if let url = Bundle.main.url(forResource: "typing", withExtension: "mp3") {
            do {
                typingAudioPlayer = try AVAudioPlayer(contentsOf: url)
                typingAudioPlayer?.volume = 0.12 // Volume baixo para não incomodar
                typingAudioPlayer?.prepareToPlay()
            } catch {
                print("Erro ao carregar áudio: \(error)")
            }
        }
    }

    // MARK: - Página

    private func showPage(index: Int, animated: Bool) {
        guard index < pages.count else {
            goToGame()
            return
        }

        currentPageIndex = index
        let page = pages[index]

        if animated {
            let fadeOut = SKAction.fadeOut(withDuration: 0.4)
            contentNode.run(fadeOut) { [weak self] in
                self?.buildPage(page)
                self?.contentNode.run(.fadeIn(withDuration: 0.4)) { [weak self] in
                    self?.startTyping()
                }
            }
        } else {
            buildPage(page)
            startTyping()
        }
    }

    private func buildPage(_ page: OnboardingPage) {
        contentNode.removeAllChildren()

        // ── Background
        let bg = SKSpriteNode(imageNamed: page.backgroundAsset)
        bg.size      = size
        bg.position  = .zero
        bg.zPosition = 0
        contentNode.addChild(bg)
        backgroundNode = bg

        // ── Caixa de texto
        let boxWidth = size.width - textPadding * 2

        let label = SKLabelNode(fontNamed: fontName)
        label.numberOfLines         = 0
        label.preferredMaxLayoutWidth = boxWidth - (textPadding * 2)
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode   = .top
        label.zPosition             = 2
        textLabel = label

        // Medir altura do texto completo com o espaçamento de linha para ajustar a caixa
        let fullLabel = SKLabelNode(fontNamed: fontName)
        fullLabel.numberOfLines = 0
        fullLabel.preferredMaxLayoutWidth = label.preferredMaxLayoutWidth
        applyAttributedText(page.text, to: fullLabel)
        
        let boxHeight = fullLabel.frame.height + (textPadding * 2.5)
        let boxY = -size.height / 2 + textPadding + boxHeight / 2

        let textBox = SKSpriteNode(imageNamed: "textbox_bg")
        textBox.size     = CGSize(width: boxWidth, height: boxHeight)
        textBox.position = CGPoint(x: 0, y: boxY)
        textBox.zPosition = 1
        contentNode.addChild(textBox)
        textBoxNode = textBox

        label.position = CGPoint(
            x: -boxWidth / 2 + textPadding,
            y:  boxHeight / 2 - textPadding
        )
        textBox.addChild(label)

        // ── Hint
        let hint = SKLabelNode(fontNamed: fontName)
        hint.fontSize  = 7
        hint.fontColor = UIColor(white: 1, alpha: 0.5)
        hint.text      = "TAP TO CONTINUE"
        hint.horizontalAlignmentMode = .right
        hint.position  = CGPoint(x: boxWidth / 2 - textPadding, y: -boxHeight / 2 + 12)
        hint.zPosition = 2
        hint.alpha     = 0
        textBox.addChild(hint)
        tapHintLabel = hint
    }

    // MARK: - Helpers de Texto

    private func applyAttributedText(_ text: String, to label: SKLabelNode) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = .left
        paragraphStyle.lineBreakMode = .byWordWrapping // Evita o efeito de blocos "pulando"

        let font = UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraphStyle
        ]

        label.attributedText = NSAttributedString(string: text, attributes: attributes)
    }

    // MARK: - Typewriter

    private func startTyping() {
        guard let label = textLabel else { return }
        let fullText = pages[currentPageIndex].text

        isTyping = true
        var currentString = ""
        let chars = Array(fullText)
        var charIndex = 0

        let typeStep = SKAction.run { [weak self] in
            guard let self = self else { return }
            if charIndex < chars.count {
                let char = chars[charIndex]
                currentString.append(char)
                self.applyAttributedText(currentString, to: label)
                
                // Som de digitação (apenas se não for espaço)
                if char != " " {
                    self.typingAudioPlayer?.stop()
                    self.typingAudioPlayer?.currentTime = 0
                    self.typingAudioPlayer?.play()
                }
                charIndex += 1
            }
        }

        let wait = SKAction.wait(forDuration: typingInterval)
        let sequence = SKAction.sequence([typeStep, wait])
        let repeatAction = SKAction.repeat(sequence, count: chars.count)

        label.run(.sequence([repeatAction, .run { [weak self] in
            self?.isTyping = false
            self?.showTapHint()
        }]), withKey: "typingAction")
    }

    private func skipTyping() {
        textLabel?.removeAction(forKey: "typingAction")
        isTyping = false
        applyAttributedText(pages[currentPageIndex].text, to: textLabel!)
        showTapHint()
    }

    private func showTapHint() {
        tapHintLabel?.run(.repeatForever(.sequence([
            .fadeAlpha(to: 0.1, duration: 0.6),
            .fadeAlpha(to: 0.7, duration: 0.6)
        ])))
    }

    // MARK: - Navegação

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
        // Desabilita interação para evitar múltiplos cliques na transição
        self.isUserInteractionEnabled = false

        // Cortina preta para transição final
        let blackOverlay = SKSpriteNode(color: .black, size: self.size)
        blackOverlay.zPosition = 100
        blackOverlay.alpha = 0
        addChild(blackOverlay)

        blackOverlay.run(.fadeIn(withDuration: 1.2)) { [weak self] in
            // Chama a transição do SwiftUI após o fade completo
            self?.onFinished?()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        advance()
    }
}
