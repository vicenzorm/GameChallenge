//
//  CutscenePlayer.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 11/03/26.
//

// MARK: - CutscenePlayer
// Exibe a cutscene como um AVPlayerLayer sobreposto ao SKView,
// SEM trocar de cena. O jogo continua pausado em background e
// retoma exatamente de onde parou quando o vídeo termina.
//
// ╔══════════════════════════════════════════════════════════════════╗
// ║                  NOME DO VÍDEO — EDITE AQUI                      ║
// ╠══════════════════════════════════════════════════════════════════╣
// ║  Arraste os .mp4 direto no Xcode (não em Assets.xcassets),       ║
// ║  marcando "Copy items if needed" + seu target.                   ║
// ║                                                                  ║
// ║  Nomeie os arquivos como:                                        ║
// ║    cutscene_wave_1.mp4   → exibida após a onda 1                 ║
// ║    cutscene_wave_2.mp4   → exibida após a onda 2                 ║
// ║    cutscene_wave_N.mp4   → e assim por diante...                 ║
// ║                                                                  ║
// ║  Se o arquivo não existir, a cutscene é pulada automaticamente.  ║
// ╚══════════════════════════════════════════════════════════════════╝

import UIKit
import AVFoundation

class CutscenePlayer: NSObject {

    // ── Arquivo de vídeo ──────────────────────────────────────────
    private static let videoExtension = "mp4"   // ← extensão do vídeo
    private static func videoName(forWave wave: Int) -> String {
        return "cutscene_wave-"           // ← padrão do nome (sem extensão)
    }

    // ── Privados ──────────────────────────────────────────────────
    private weak var parentView: UIView?
    private var player:       AVPlayer?
    private var playerLayer:  AVPlayerLayer?
    private var endObserver:  Any?
    private var skipButton:   UIButton?
    private var onFinished:   (() -> Void)?

    // MARK: - API pública

    /// Tenta exibir o vídeo da onda `wave` sobre `view`.
    /// Se o arquivo não existir, chama `onFinished` imediatamente.
    func play(wave: Int, over view: UIView, onFinished: @escaping () -> Void) {
        self.parentView  = view
        self.onFinished  = onFinished

        let name = CutscenePlayer.videoName(forWave: wave)
        let ext  = CutscenePlayer.videoExtension

        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            // Sem vídeo para esta onda → pula
            onFinished()
            return
        }

        setupPlayer(url: url, over: view)
    }

    // MARK: - Setup

    private func setupPlayer(url: URL, over view: UIView) {
        let item   = AVPlayerItem(url: url)
        let avPlayer = AVPlayer(playerItem: item)
        self.player = avPlayer

        // Camada de vídeo cobre toda a view
        let layer = AVPlayerLayer(player: avPlayer)
        layer.frame           = view.bounds
        layer.videoGravity    = .resizeAspect
        layer.backgroundColor = UIColor.black.cgColor
        view.layer.addSublayer(layer)
        self.playerLayer = layer

        // Observa fim do vídeo
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            self?.finish()
        }

        avPlayer.play()
        addSkipButton(to: view)
    }

    private func addSkipButton(to view: UIView) {
        let btn = UIButton(type: .system)
        btn.setTitle("SKIP ▶▶", for: .normal)
        btn.titleLabel?.font    = UIFont(name: AppManager.shared.secondaryFont, size: 14)
        btn.setTitleColor(UIColor(white: 0.85, alpha: 1), for: .normal)
        btn.backgroundColor     = UIColor.black.withAlphaComponent(0.55)
        btn.layer.cornerRadius  = 8
        btn.layer.borderWidth   = 1
        btn.layer.borderColor   = UIColor(white: 1, alpha: 0.35).cgColor
        btn.frame               = CGRect(x: view.bounds.width  - 110,
                                         y: view.bounds.height - 50,
                                         width: 96, height: 32)
        btn.autoresizingMask    = [.flexibleLeftMargin, .flexibleTopMargin]
        btn.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        view.addSubview(btn)
        self.skipButton = btn
    }

    // MARK: - Finish

    @objc private func skipTapped() { finish() }

    private func finish() {
        // Garante execução única
        guard let cb = onFinished else { return }
        onFinished = nil

        tearDown()
        cb()
    }

    private func tearDown() {
        player?.pause()
        player = nil

        if let obs = endObserver {
            NotificationCenter.default.removeObserver(obs)
            endObserver = nil
        }

        playerLayer?.removeFromSuperlayer()
        playerLayer = nil

        skipButton?.removeFromSuperview()
        skipButton = nil
    }
}
