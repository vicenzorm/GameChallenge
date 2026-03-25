//
//  MusicManager.swift
//  GameChallenge
//
//  Created by Bernardo Garcia Fensterseifer on 24/03/26.
//


//
//  MusicManager.swift
//

import AVFoundation

class MusicManager {
    static let shared = MusicManager()
    private init() {}

    private var player: AVAudioPlayer?
    private var currentTrack: String?

    // MARK: - Public API

    func play(_ trackName: String, loop: Bool = true) {
        guard AppManager.shared.soundEnabled else { return }
        guard trackName != currentTrack else { return }  // já tocando

        stop()

        guard let url = Bundle.main.url(forResource: trackName, withExtension: nil) else {
            print("⚠️ MusicManager: arquivo não encontrado — \(trackName)")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = loop ? -1 : 0
            player?.volume = 0
            player?.prepareToPlay()
            player?.play()
            fadeIn()
            currentTrack = trackName
        } catch {
            print("⚠️ MusicManager: erro ao carregar \(trackName) — \(error)")
        }
    }

    func stop(fadeDuration: TimeInterval = 0.5) {
        fadeOut(duration: fadeDuration) { [weak self] in
            self?.player?.stop()
            self?.player = nil
            self?.currentTrack = nil
        }
    }

    /// Chama quando o usuário liga/desliga música nas configurações.
    func applySettings() {
        if AppManager.shared.soundEnabled {
            player?.play()
            fadeIn()
        } else {
            player?.pause()
        }
    }

    // MARK: - Fade helpers

    private func fadeIn(duration: TimeInterval = 0.8, targetVolume: Float = 0.5) {
        guard let player else { return }
        player.volume = 0
        let steps = 20
        let stepTime = duration / Double(steps)
        let stepVol  = targetVolume / Float(steps)
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepTime * Double(i)) {
                player.volume = Swift.min(stepVol * Float(i), targetVolume)
            }
        }
    }

    private func fadeOut(duration: TimeInterval = 0.5, completion: @escaping () -> Void) {
        guard let player, player.isPlaying else { completion(); return }
        let startVolume = player.volume
        let steps = 20
        let stepTime = duration / Double(steps)
        let stepVol  = startVolume / Float(steps)
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepTime * Double(i)) {
                player.volume = Swift.max(startVolume - stepVol * Float(i), 0)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { completion() }
    }
}