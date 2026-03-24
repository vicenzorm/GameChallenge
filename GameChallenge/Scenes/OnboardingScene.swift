//
//  OnboardingScene.swift
//  GameChallenge
//
//  Created by Bernardo Garcia Fensterseifer on 23/03/26.
//

import SpriteKit

class OnboardingScene: SKScene {
    
    // ── Callback para avisar o SwiftUI que terminou ───────────────────
        var onFinished: (() -> Void)?

        // Adicione esse init para o SpriteView conseguir instanciar sem parâmetros
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
    private var typingAction:    SKAction?

    // ── Nodes ─────────────────────────────────────────────────────────
    private var backgroundNode:  SKSpriteNode?
    private var textBoxNode:     SKSpriteNode?
    private var textLabel:       SKLabelNode?
    private var tapHintLabel:    SKLabelNode?

    // ── Configurações ─────────────────────────────────────────────────
    private let fontName        = "PressStart2P-Regular"
    private let fontSize:        CGFloat = 11
    private let textPadding:     CGFloat = 24
    private let typingInterval:  TimeInterval = 0.04   // ← velocidade de digitação
    private let typeSound        = SKAction.playSoundFileNamed("typing.wav", waitForCompletion: false)

    // ── Música ────────────────────────────────────────────────────────
    // Para ativar: descomente a linha abaixo e implemente via SoundManager
    // SoundManager.shared.playMusic(name: "onboarding_soundtrack", volume: 0.6)

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)

        // ── Música de fundo ───────────────────────────────────────────
        // Descomente para ativar:
        // SoundManager.shared.playMusic(name: "onboarding_soundtrack", volume: 0.6)

        showPage(index: 0, animated: false)
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
            // Fade out da tela atual, depois monta a nova
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            run(fadeOut) { [weak self] in
                self?.buildPage(page)
                self?.run(.fadeIn(withDuration: 0.5)) { [weak self] in
                    self?.startTyping()
                }
            }
        } else {
            buildPage(page)
            startTyping()
        }
    }

    private func buildPage(_ page: OnboardingPage) {
        // Remove tudo anterior
        removeAllChildren()

        // ── Background ────────────────────────────────────────────────
        let bg = SKSpriteNode(imageNamed: page.backgroundAsset)
        bg.size      = size
        bg.position  = .zero
        bg.zPosition = 0
        addChild(bg)
        backgroundNode = bg

        // ── Caixa de texto ────────────────────────────────────────────
        // Calcula largura disponível respeitando padding lateral
        let boxWidth = size.width - textPadding * 2

        // Label com numberOfLines para quebra automática
        let label = SKLabelNode(fontNamed: fontName)
        label.fontSize              = fontSize
        label.fontColor             = .white
        label.numberOfLines         = 0
        label.preferredMaxLayoutWidth = boxWidth - textPadding * 2
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode   = .top
        label.text                  = ""   // começa vazio — será preenchido pelo typewriter
        label.zPosition             = 2
        textLabel = label

        // Altura da caixa baseada no texto completo (para reservar espaço certo)
        let fullLabel = SKLabelNode(fontNamed: fontName)
        fullLabel.fontSize              = fontSize
        fullLabel.numberOfLines         = 0
        fullLabel.preferredMaxLayoutWidth = boxWidth - textPadding * 2
        fullLabel.text                  = page.text
        let textHeight = fullLabel.frame.height

        let boxHeight = textHeight + textPadding * 2

        // Posição: alinhada ao fundo com padding
        let boxY = -size.height / 2 + textPadding + boxHeight / 2

        // Imagem de fundo da caixa de texto
        let textBox = SKSpriteNode(imageNamed: "textbox_bg")
        textBox.size     = CGSize(width: boxWidth, height: boxHeight)
        textBox.position = CGPoint(x: 0, y: boxY)
        textBox.zPosition = 1
        addChild(textBox)
        textBoxNode = textBox

        // Posiciona o label dentro da caixa
        label.position = CGPoint(
            x: -boxWidth / 2 + textPadding,
            y:  boxHeight / 2 - textPadding
        )
        textBox.addChild(label)

        // ── Hint "tap to continue" ────────────────────────────────────
        let hint = SKLabelNode(fontNamed: fontName)
        hint.fontSize  = 8
        hint.fontColor = UIColor(white: 1, alpha: 0.6)
        hint.text      = "tap to continue"
        hint.horizontalAlignmentMode = .right
        hint.position  = CGPoint(x: boxWidth / 2 - textPadding, y: -boxHeight / 2 + 10)
        hint.zPosition = 2
        hint.alpha     = 0
        textBox.addChild(hint)
        tapHintLabel = hint

        alpha = 1
    }

    // MARK: - Typewriter

    private func startTyping() {
        guard let label = textLabel else { return }
        let page = pages[currentPageIndex]
        let fullText = page.text

        isTyping = true
        label.text = ""

        var charIndex = 0
        let chars = Array(fullText)

        // Sequência: a cada `typingInterval` adiciona um caractere + toca som
        let typeStep = SKAction.run { [weak self, weak label] in
            guard let self, let label else { return }
            guard charIndex < chars.count else { return }
            label.text = (label.text ?? "") + String(chars[charIndex])
            charIndex += 1

            // Som de digitação (não toca para espaços para não ficar repetitivo)
            if chars[charIndex > 0 ? charIndex - 1 : 0] != " " {
                self.run(self.typeSound)
            }
        }

        let wait     = SKAction.wait(forDuration: typingInterval)
        let sequence = SKAction.sequence([typeStep, wait])
        let repeat_  = SKAction.repeat(sequence, count: chars.count)

        let finish = SKAction.run { [weak self] in
            self?.isTyping = false
            self?.showTapHint()
        }

        run(.sequence([repeat_, finish]), withKey: "typing")
    }

    private func skipTyping() {
        removeAction(forKey: "typing")
        isTyping = false
        textLabel?.text = pages[currentPageIndex].text
        showTapHint()
    }

    private func showTapHint() {
        tapHintLabel?.run(.repeatForever(.sequence([
            .fadeAlpha(to: 0.2, duration: 0.6),
            .fadeAlpha(to: 0.8, duration: 0.6)
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

//    private func goToGame() {
//        // ── Para música do onboarding ─────────────────────────────────
//        // SoundManager.shared.stopMusic()
//
//        let game = MenuScene(size: size)   // ← troque por GameScene se quiser ir direto
//        game.scaleMode = scaleMode
//        view?.presentScene(game, transition: .fade(withDuration: 0.8))
//    }

    // MARK: - Touch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        advance()
    }
    
    private func goToGame() {
            // ── Para música do onboarding ─────────────────────────────────
            // SoundManager.shared.stopMusic()

            // Avisa o SwiftUI para trocar de tela
            onFinished?()
        }

}
