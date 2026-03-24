import SpriteKit
import AVFoundation

final class SoundManager {

    static let shared = SoundManager()

    // MARK: - Music
    private var musicPlayer: AVAudioPlayer?

    // MARK: - SFX (pré-criados)
    let button = SKAction.playSoundFileNamed("button.wav", waitForCompletion: false)
    let buttonSpecial = SKAction.playSoundFileNamed("buttonSpecial.wav", waitForCompletion: false)
    let toggle = SKAction.playSoundFileNamed("toggle.wav", waitForCompletion: false)

    let hit1 = SKAction.playSoundFileNamed("hit1.wav", waitForCompletion: false)
    let hit2 = SKAction.playSoundFileNamed("hit2.wav", waitForCompletion: false)

    let attack1 = SKAction.playSoundFileNamed("attack1.wav", waitForCompletion: false)
    let attack2 = SKAction.playSoundFileNamed("attack2.mp3", waitForCompletion: false)

    let damage = SKAction.playSoundFileNamed("hit1.wav", waitForCompletion: false)
    let playerDamaged = SKAction.playSoundFileNamed("hit1.wav", waitForCompletion: false)
    let death = SKAction.playSoundFileNamed("hit1.wav", waitForCompletion: false)
    let enemyKilled = SKAction.playSoundFileNamed("enemyKilled.wav", waitForCompletion: false)

    let footstep = SKAction.playSoundFileNamed("footstep.wav", waitForCompletion: false)
    
    let swordAttack1  = SKAction.playSoundFileNamed("swordAttack1.wav",  waitForCompletion: false)  // skeleton
    let swordAttack2  = SKAction.playSoundFileNamed("swordAttack2.wav",  waitForCompletion: false)  // yellowSkeleton
    let flameShot     = SKAction.playSoundFileNamed("flameShot.wav",     waitForCompletion: false)  // fireball
    let monsterBite   = SKAction.playSoundFileNamed("monsterBite.wav",   waitForCompletion: false)  // bix

    private init() {}

    // MARK: - Play SFX
    func play(_ sound: SKAction, on node: SKNode) {
        guard AppManager.shared.sFXEnabled else { return }
        node.run(sound)
    }

    // MARK: - Music
    func playMusic(name: String, volume: Float, loop: Bool = true) {

        guard AppManager.shared.soundEnabled else { return }

        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("music not found: \(name)")
            return
        }

        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.volume = volume
            musicPlayer?.numberOfLoops = loop ? -1 : 0
            musicPlayer?.prepareToPlay()
            musicPlayer?.play()
        } catch {
            print(error)
        }
    }

    func stopMusic() {
        musicPlayer?.stop()
    }

    func fadeOutMusic(duration: TimeInterval) {
        musicPlayer?.setVolume(0, fadeDuration: duration)
    }

    func setMusicVolume(_ volume: Float) {
        musicPlayer?.volume = volume
    }
    
    
}
