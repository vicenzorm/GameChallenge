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
    let flameHit = SKAction.playSoundFileNamed( "flameHit.wav", waitForCompletion: false)
    
    let hitBoxComponent = SKAction.playSoundFileNamed("hitWood.wav",waitForCompletion: false)
    let firePutOut = SKAction.playSoundFileNamed("firePutOut.wav", waitForCompletion: false)
    let clinkingCoins = SKAction.playSoundFileNamed("clinkingCoins.wav", waitForCompletion: false)
    let vaseBreak = SKAction.playSoundFileNamed("vaseBreak", waitForCompletion: false)

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
    
    let healthPickup = SKAction.playSoundFileNamed("healthPickup.wav", waitForCompletion: false)  
    let specialPickup = SKAction.playSoundFileNamed("specialPickup.wav", waitForCompletion: false)
    let killAll = SKAction.playSoundFileNamed( "killAll.wav", waitForCompletion: false)
    
    let musicMenu = SKAction.playSoundFileNamed( "menuSoundtrack.mp3", waitForCompletion: false)
    let gameMusic = SKAction.playSoundFileNamed( "gameMusic.mp3", waitForCompletion: false)
    let gameOverMusic = SKAction.playSoundFileNamed( "gameOverMusic.mp3", waitForCompletion: false)
    let levelUpMusic = SKAction.playSoundFileNamed( "levelUpMusic.mp3", waitForCompletion: false)
    
    // Adicione esta propriedade na classe:
    private var currentMusicURL: URL?
    
    private init() {}

    // MARK: - Play SFX
    func play(_ sound: SKAction, on node: SKNode) {
        guard AppManager.shared.sFXEnabled else { return }
        node.run(sound)
    }

    // MARK: - Music
    func playMusic(named fileName: String, volume: Float = 0.5, loop: Bool = true) {
        guard AppManager.shared.soundEnabled else { return }

        let url: URL?
        if let dotIndex = fileName.lastIndex(of: ".") {
            let name = String(fileName[fileName.startIndex..<dotIndex])
            let ext  = String(fileName[fileName.index(after: dotIndex)...])
            url = Bundle.main.url(forResource: name, withExtension: ext)
        } else {
            url = Bundle.main.url(forResource: fileName, withExtension: "mp3")
        }

        guard let url else {
            print("⚠️ SoundManager: música não encontrada — \(fileName)")
            return
        }

        guard currentMusicURL != url else { return }

        // Fade out da música atual, depois toca a nova
        let fadeDuration: TimeInterval = musicPlayer?.isPlaying == true ? 0.4 : 0.0
        musicPlayer?.setVolume(0, fadeDuration: fadeDuration)

        DispatchQueue.main.asyncAfter(deadline: .now() + fadeDuration) { [weak self] in
            guard let self else { return }
            self.musicPlayer?.stop()
            self.currentMusicURL = url
            do {
                self.musicPlayer = try AVAudioPlayer(contentsOf: url)
                self.musicPlayer?.volume = 0
                self.musicPlayer?.numberOfLoops = loop ? -1 : 0
                self.musicPlayer?.prepareToPlay()
                self.musicPlayer?.play()
                self.musicPlayer?.setVolume(volume, fadeDuration: 0.8)
            } catch {
                print("⚠️ SoundManager: erro ao tocar \(fileName) — \(error)")
            }
        }
    }
    
    func applyMusicSettings() {
        if AppManager.shared.soundEnabled {
            musicPlayer?.play()
        } else {
            musicPlayer?.pause()
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
