//
//  SoundManager.swift
//  SSC1
//
//  Created by Vicenzo Másera on 07/01/26.
//

import Foundation
import AVFoundation

class SoundManager {
    static let soundEffects = SoundManager()
    static let mainSoundTrack = SoundManager()
    private var audioPlayer: AVAudioPlayer?
    private var isPlaying: Bool = false
    
    func playAudio(audio: String, type: String = "mp3", loop: Bool, volume: Float) {
        if AppManager.shared.soundEnabled {
            guard let audioURL = Bundle.main.url(forResource: audio, withExtension: type) else {
                print("audio file not found: \(audio).\(type)")
                return
            }
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
                try AVAudioSession.sharedInstance().setActive(true)
                audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                audioPlayer?.volume = volume
                audioPlayer?.numberOfLoops = loop ? -1 : 0
                audioPlayer?.enableRate = true
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                print(error)
            }
        }
    }
    
    func stopSounds() {
        audioPlayer?.stop()
        isPlaying = false
    }
    
    func playStartButtonSound() {
        playAudio(audio: "buttonSpecial", type: "wav", loop: false, volume: 0.5)
    }
    
    func playButtonSound() {
        playAudio(audio: "button", type: "wav", loop: false, volume: 0.5)
    }
    
    func playToggleSound() {
        playAudio(audio: "toggle", type: "wav", loop: false, volume: 0.5)
    }
    
    func playHitAttack1Sound() {
        playAudio(audio: "hit1", type: "wav", loop: false, volume: 0.35)
    }
    
    func playHitAttack2Sound() {
        playAudio(audio: "hit2", type: "wav", loop: false, volume: 0.35)
    }
    
    func playDamageSound() {
        playAudio(audio: "damage", type: "wav", loop: false, volume: 0.35)
    }
    
    func attack1Sound() {
        playAudio(audio: "attack1", type: "wav", loop: false, volume: 0.35)
    }
    
    func attack2Sound() {
        playAudio(audio: "attack2", type: "wav", loop: false, volume: 0.35)
    }
    
    func footstepSound() {
        playAudio(audio: "footstep", type: "wav", loop: false, volume: 0.35)
    }
    
    func deathSound() {
        playAudio(audio: "death", type: "wav", loop: false, volume: 0.35)
    }
    
    func enemyKilledSound() {
        playAudio(audio: "enemyKilled", type: "wav", loop: false, volume: 0.35)
    }
    
    func playMenuMusic() {
        playAudio(audio: "menuMusic", loop: true, volume: 0.3)
        isPlaying = true
        
    }
    
    func playGameplayMusic() {
        playAudio(audio: "gameplayMusic", loop: true, volume: 0.2)
        isPlaying = true
    }
    
    func fadeOutMusic(duration: TimeInterval) {
        if let audioPlayer, isPlaying {
            audioPlayer.setVolume(0, fadeDuration: duration)
        }
    }
    
    func setVolume(_ volume: Float) {
        guard let audioPlayer else { return }
        audioPlayer.volume = volume
    }
    
}
