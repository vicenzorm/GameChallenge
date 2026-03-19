//
//  DarknessOverlay.swift
//  POC-2DGame
//

/*
 Valor          Sensação
 120            Claustrofóbico, tensão alta
 160            Padrão
 220            Confortável, vê bem ao redor
 300            Bem aberto, pouca escuridão
 400            Quase sem efeito
 */

import SpriteKit
import UIKit

final class DarknessOverlay: SKNode {

    // ── Propriedades públicas ─────────────────────────────────────────────────

    /// Raio (pontos de cena) da área iluminada. Mude a qualquer momento.
    var lightRadius: CGFloat = 120 {
        didSet { if oldValue != lightRadius { rebuildTexture() } }
    }

    /// Opacidade do preto nas bordas. 0 = invisível · 1 = preto total.
    var darkness: CGFloat = 0.92 {
        didSet { if oldValue != darkness { rebuildTexture() } }
    }

    /// Largura da transição suave entre claro e escuro.
    var softness: CGFloat = 220 {
        didSet { if oldValue != softness { rebuildTexture() } }
    }

    // ── Privado ───────────────────────────────────────────────────────────────

    private let overlayNode: SKSpriteNode
    private let screenSize:  CGSize

    // Tamanho real da textura: muito maior que a tela para cobrir cantos e bordas
    // quando a câmera fica presa. 3× garante cobertura mesmo no canto mais extremo.
    private var canvasSize: CGSize {
        CGSize(width: screenSize.width * 3, height: screenSize.height * 3)
    }

    // ── Init ──────────────────────────────────────────────────────────────────

    init(screenSize: CGSize, lightRadius: CGFloat = 160) {
        self.screenSize = screenSize

        overlayNode             = SKSpriteNode()
        overlayNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        // IMPORTANTE: blendMode .alpha causa a "bola preta".
        // .multiply escurece multiplicando as cores — preto vira preto,
        // transparente não afeta nada. É o blend correto para escuridão.
        // MAS: para termos transparência real no buraco, usamos uma abordagem
        // diferente — a textura tem canal alpha e usamos blendMode padrão (.alpha),
        // mas geramos a textura de forma que o buraco seja TOTALMENTE transparente
        // (alpha = 0) e as bordas sejam preto opaco (alpha = darkness).
        // O truque que causava a bola preta era o gradiente invertido — agora corrigido.
        overlayNode.blendMode   = .alpha
        overlayNode.zPosition   = 60   // acima do mundo, abaixo da HUD (99) e Pause (200)

        super.init()

        addChild(overlayNode)
        rebuildTexture()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // ── API pública ───────────────────────────────────────────────────────────

    func update(playerPositionInScene playerPos: CGPoint,
                cameraPosition        camPos:    CGPoint) {
        overlayNode.position = CGPoint(x: playerPos.x - camPos.x,
                                       y: playerPos.y - camPos.y)
    }

    // ── Geração de textura ────────────────────────────────────────────────────

    private func rebuildTexture() {
        let size = canvasSize
        guard size.width > 0, size.height > 0 else { return }

        let cx = size.width  / 2
        let cy = size.height / 2

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(
            data:             nil,
            width:            Int(size.width),
            height:           Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow:      0,
            space:            colorSpace,
            bitmapInfo:       CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            print("[DarknessOverlay] ERRO: falha ao criar CGContext")
            return
        }

        // ── Passo 1: começa tudo TRANSPARENTE ────────────────────────────────
        // (CGContext novo já é todo zeros = transparente)

        // ── Passo 2: desenha o gradiente radial diretamente ───────────────────
        // O gradiente vai de TRANSPARENTE no centro para PRETO OPACO nas bordas.
        // Isso elimina completamente a "bola preta" — não há fill preto + clear,
        // há apenas um gradiente de alpha que vai de 0 (centro) a darkness (borda).

        let innerRadius: CGFloat = lightRadius * 0.1   // núcleo: quase ponto
        let outerRadius: CGFloat = lightRadius + softness  // fim da transição suave

        let gradient = makeGradient()

        ctx.drawRadialGradient(
            gradient,
            startCenter: CGPoint(x: cx, y: cy), startRadius: innerRadius,
            endCenter:   CGPoint(x: cx, y: cy), endRadius:   outerRadius,
            options: [.drawsAfterEndLocation]  // preenche TUDO além do raio externo com a cor final (preto opaco)
        )

        guard let cgImage = ctx.makeImage() else {
            print("[DarknessOverlay] ERRO: falha ao gerar CGImage")
            return
        }

        let tex = SKTexture(cgImage: cgImage)
        tex.filteringMode   = .linear
        overlayNode.texture = tex
        overlayNode.size    = size

        print("[DarknessOverlay] OK — canvas: \(size), radius: \(lightRadius), softness: \(softness)")
    }

    /// Gradiente: centro = transparente, borda = preto opaco.
    /// A transição tem 3 stops para criar o efeito âmbar de tocha.
    private func makeGradient() -> CGGradient {
        let space = CGColorSpaceCreateDeviceRGB()

        // Cada linha: R, G, B, A
        // O canal A vai de 0 (transparente = área iluminada) para `darkness` (escuro)
        // A cor RGB não importa onde alpha=0, mas onde começa a aparecer
        // usamos um tom âmbar quente para dar sensação de tocha.
        let d = darkness
        let comps: [CGFloat] = [
            // R      G      B      A          stop    descrição
            0.00,  0.00,  0.00,  0.00,   //  0.0  — centro: totalmente transparente
            0.10,  0.06,  0.02,  d * 0.15, //  0.35 — início da penumbra (quase invisível)
            0.05,  0.03,  0.01,  d * 0.55, //  0.65 — penumbra média
            0.00,  0.00,  0.00,  d,        //  1.0  — escuridão total
        ]
        let locs: [CGFloat] = [0.0, 0.35, 0.65, 1.0]

        return CGGradient(colorSpace: space,
                          colorComponents: comps,
                          locations: locs,
                          count: locs.count)!
    }
}
