//
//  GameScene.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 11/03/26.
//

/// GameScene.swift
/// The primary gameplay scene responsible for:
/// - Creating and configuring the world (background, borders)
/// - Wiring up the camera, HUD, and on-screen joystick
/// - Spawning the player and reacting to wave/coin system callbacks
/// - Driving the frame-by-frame game loop to update systems (input, movement, AI, combat, health, collisions)
///
/// Architecture overview:
/// - ECS: Entities aggregate Components; Systems operate on Entities/Components
/// - Scenes: GameScene orchestrates systems and passes data between them
/// - UI: HUD and Joystick are attached to the camera to remain screen-fixed
/// - Systems: MovementSystem, InputSystem, PlayerSystem, EnemyAISystem, HealthSystem, CollisionSystem, WaveSystem, CoinSpawnSystem
///
/// Notes:
/// - Keep scene responsibilities thin: create, connect, and sequence — let Systems do the work
/// - Avoid storing transient state in the scene when it belongs in Components/Systems

// MARK: - GameScene

import SpriteKit
import CoreMotion

// ╔══════════════════════════════════════════════════════════╗
// ║              ASSET NAMES — EDIT HERE                     ║
// ╠══════════════════════════════════════════════════════════╣
// ║  background_tile  → world background image               ║
// ╚══════════════════════════════════════════════════════════╝
private let kBackgroundAsset = "background_tile"  // ← your background image in Assets.xcassets

class GameScene: SKScene {

    // MARK: ECS
    private var playerEntity:  Entity!
    private var enemyEntities: [Entity] = []
    private var coinEntities:  [Entity] = []

    // Systems
    private let movementSystem   = MovementSystem()
    private let inputSystem      = InputSystem()
    private let playerSystem     = PlayerSystem()
    private let attackSystem     = AttackSystem()
    private let enemyAISystem    = EnemyAISystem()
    private let healthSystem     = HealthSystem()
    private let collisionSystem  = CollisionSystem()
    private let waveSystem       = WaveSystem()
    private let coinSpawnSystem  = CoinSpawnSystem()

    // MARK: UI
    private var hud:        HUD!
    private var cameraNode: SKCameraNode!
    private var joystick:   Joystick!

    // Cutscene (retido aqui para não ser desalocado durante o vídeo)
    private var cutscenePlayer: CutscenePlayer?

    // Pause state
    private var isPausedByPlayer = false
    private var pauseNode: Pause!

    // World size
    private let worldSize = CGSize(width: 2400, height: 2400)
    
    override init(size: CGSize) {
        pauseNode = Pause(size: size)
        super.init(size: size)
        addChild(pauseNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Scene entry point: constructs world, camera, UI, player, and wires callbacks.
    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        setupWorld()
        setupCamera()
        setupJoystick()
        setupHUD(view: view)
        setupPlayer()
        setupWaveCallbacks()
        setupCoinCallbacks()
        waveSystem.startNextWave(sceneSize: worldSize)
    }
    

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        layoutJoystick()
    }

    // MARK: Setup

    /// Builds the visible world (tiled background + border) and adds it to the scene.
    private func setupWorld() {
        // Tiled background using the asset image
        let tileSize = CGSize(width: 256, height: 256)   // ← adjust to match your image size
        let cols = Int(ceil(worldSize.width  / tileSize.width))  + 1
        let rows = Int(ceil(worldSize.height / tileSize.height)) + 1

        for row in 0...rows {
            for col in 0...cols {
                let tile = SKSpriteNode(imageNamed: kBackgroundAsset)
                tile.size      = tileSize
                tile.position  = CGPoint(
                    x: -worldSize.width  / 2 + CGFloat(col) * tileSize.width  - tileSize.width  / 2,
                    y: -worldSize.height / 2 + CGFloat(row) * tileSize.height - tileSize.height / 2
                )
                tile.zPosition = -10
                addChild(tile)
            }
        }

        // World border
        let border = SKShapeNode(rectOf: worldSize)
        border.strokeColor = UIColor(white: 0.5, alpha: 0.8)
        border.fillColor   = .clear
        border.lineWidth   = 4
        border.zPosition   = -5
        addChild(border)
    }

    /// Creates and adds the camera node, setting its zPosition and linking it to the scene.
    private func setupCamera() {
        cameraNode          = SKCameraNode()
        cameraNode.zPosition = 50
        addChild(cameraNode)
        camera = cameraNode
    }

    /// Initializes the joystick, adds it to the camera, and makes it visible and interactive.
    private func setupJoystick() {
        joystick = Joystick()
        cameraNode.addChild(joystick)
        joystick.isHidden = false
        joystick.isUserInteractionEnabled = true
        layoutJoystick()
    }
    
    /// Positions the joystick in the bottom-left of the camera's visible area.
    /// Safe to call multiple times (e.g., on rotation/resize). No-ops if scene/joystick not ready.
    private func layoutJoystick() {
        // Ensure we have a joystick and camera before laying out
        guard let joystick = joystick, let scene = self.scene ?? self as SKScene? else { return }
        let margin: CGFloat = 80
        // Scene size represents the camera's visible rect when camera is centered and scaleMode applied
        let width  = scene.size.width
        let height = scene.size.height
        // Convert to camera's local coordinate space: camera's origin is its center
        joystick.position = CGPoint(x: -width/2 + margin, y: -height/2 + margin)
    }

    /// Creates and adds the HUD to the camera node.
    private func setupHUD(view: SKView) {
        hud = HUD(screenSize: view.bounds.size)
        cameraNode.addChild(hud)
    }

    /// Spawns the player entity at the scene center.
    private func setupPlayer() {
        playerEntity = EntityFactory.makePlayer(at: .zero, scene: self)
    }

    /// Connects wave system callbacks to spawn enemies, update HUD, and handle cutscenes.
    private func setupWaveCallbacks() {
        waveSystem.onSpawnEnemy = { [weak self] type, pos in
            guard let self else { return }
            self.enemyEntities.append(EntityFactory.makeEnemy(type: type, at: pos, scene: self))
        }
        waveSystem.onWaveStart = { [weak self] wave in
            self?.hud.updateWave(wave)
            self?.showWaveBanner(wave: wave)
        }
        waveSystem.onWaveEnd = { [weak self] completedWave in
            // Exibe cutscene como overlay sobre o SKView — sem trocar de cena.
            // Se não existir vídeo "cutscene_wave_N.mp4" no bundle, é pulada automaticamente.
            guard let self, let view = self.view else { return }
            self.isPausedByPlayer = true

            let cp = CutscenePlayer()
            self.cutscenePlayer = cp   // retém para não ser desalocado
            cp.play(wave: completedWave, over: view) { [weak self] in
                // Vídeo terminou ou foi pulado → retoma o jogo
                self?.cutscenePlayer  = nil
                self?.isPausedByPlayer = false
            }
        }
        waveSystem.onWaveCountdown = { [weak self] seconds in
            self?.hud.showCountdown(seconds)
        }
    }

    /// Connects coin spawn system callbacks to spawn coins in the scene.
    private func setupCoinCallbacks() {
        coinSpawnSystem.onSpawnCoin = { [weak self] pos in
            guard let self else { return }
            self.coinEntities.append(EntityFactory.makeCoin(at: pos, scene: self))
        }
    }

    /// Main game loop: gathers input, updates systems in a deterministic order, and syncs the HUD.
    override func update(_ currentTime: TimeInterval) {
        guard !isPausedByPlayer else { return }
        let dt = calculateDeltaTime(currentTime)

        // 1. Get joystick input
        let movementDirection = joystick.velocity
        let movementVector = CGVector(dx: movementDirection.x, dy: movementDirection.y)
        inputSystem.update(playerEntity: playerEntity, joystickDirection: CGPoint(x: movementVector.dx, y: movementVector.dy))

        // 2. Player
        playerSystem.update(
            playerEntity:    playerEntity,
            motionDirection: CGVector(dx: movementVector.dx, dy: movementVector.dy),  // Using joystick direction instead of motion
            deltaTime:       dt,
            currentTime:     currentTime
        )

        // 3. Enemy AI
        enemyAISystem.update(enemies: enemyEntities, playerEntity: playerEntity, deltaTime: dt)

        // 4. Movement system moves all dynamic entities (player + enemies) using velocity/acceleration from components
        movementSystem.update(entities: [playerEntity!] + enemyEntities, deltaTime: dt)

        // 5. Camera follows player
        if let node = playerEntity.get(TransformComponent.self)?.node {
            cameraNode.position = node.position
            pauseNode.position = node.position
        }

        // 6. Attack
        if let attack = playerEntity.get(AttackComponent.self), attack.isAttacking {
            attackSystem.update(attackerEntity: playerEntity, enemies: enemyEntities, scene: self)
            hud.flashButtonA()
        }

        // 7. Health bars
        healthSystem.update(entities: enemyEntities)

        // 8. Enemy → player collision
        collisionSystem.checkEnemyPlayerCollisions(
            playerEntity: playerEntity, enemies: enemyEntities, deltaTime: dt)

        // 9. Coin collection
        let collected = collisionSystem.checkCoinCollection(
            playerEntity: playerEntity, coins: coinEntities)
        for coin in collected {
            if let cc = coin.get(CoinComponent.self),
               let pl = playerEntity.get(PlayerComponent.self) { pl.coins += cc.value }
            coin.get(TransformComponent.self)?.node.removeFromParent()
        }
        let collectedIDs = Set(collected.map { $0.id })
        coinEntities.removeAll { collectedIDs.contains($0.id) }

        // 10. Dead enemies
        var killedPts = 0
        let dead = enemyEntities.filter { $0.get(HealthComponent.self)?.isAlive == false }
        for d in dead {
            if let t = d.get(EnemyComponent.self)?.type {
                killedPts += t.specialPoints
                maybeDropCoin(at: d.get(TransformComponent.self)?.node.position ?? .zero)
            }
            d.get(TransformComponent.self)?.node.run(.sequence([
                .scale(to: 0.1, duration: 0.12), .removeFromParent()
            ]))
        }
        let deadIDs = Set(dead.map { $0.id })
        enemyEntities.removeAll { deadIDs.contains($0.id) }

        // 11. Special charge
        if let pl = playerEntity.get(PlayerComponent.self) {
            pl.killStreak += killedPts
            if pl.killStreak >= PlayerComponent.weakKillsNeeded && !pl.specialReady {
                pl.specialReady = true
            }
            hud.updateSpecial(killStreak: pl.killStreak, isReady: pl.specialReady)
            hud.setButtonBActive(pl.specialReady)
        }

        // 12. HUD health + game over
        if let h = playerEntity.get(HealthComponent.self) {
            hud.updateHealth(current: h.current, maxHP: h.max)
            if !h.isAlive { triggerGameOver() }
        }

        // 13. HUD coins
        if let pl = playerEntity.get(PlayerComponent.self) { hud.updateCoins(pl.coins) }

        // 14. Wave + coin spawn
        if let node = playerEntity.get(TransformComponent.self)?.node {
            waveSystem.update(deltaTime: dt, activeEnemies: enemyEntities.count,
                              sceneSize: worldSize, playerPosition: node.position)
        }
        coinSpawnSystem.update(deltaTime: dt, activeCoins: coinEntities.count, sceneSize: worldSize)
    }

    /// Toggles pause state and updates HUD accordingly.
    func togglePause() {
        isPausedByPlayer.toggle()
//        hud.showPauseOverlay(isPausedByPlayer)
        pauseNode.pauseGame()
    }

    /// Calculates time delta for frame updates, capped at 1/30th second.
    private func calculateDeltaTime(_ t: TimeInterval) -> TimeInterval {
        let dt = lastUpdateTime == 0 ? 0 : Swift.min(t - lastUpdateTime, 1.0/30.0)
        lastUpdateTime = t
        return dt
    }

    /// Randomly drops a coin at the specified position with a 1 in 3 chance.
    private func maybeDropCoin(at pos: CGPoint) {
        guard Int.random(in: 0..<3) == 0 else { return }
        coinEntities.append(EntityFactory.makeCoin(at: pos, scene: self))
    }

    /// Displays a wave banner at the center of the screen.
    private func showWaveBanner(wave: Int) {
        let lbl = SKLabelNode(text: "WAVE \(wave)")
        lbl.fontName  = "AvenirNext-Heavy"
        lbl.fontSize  = 32
        lbl.fontColor = .white
        lbl.position  = .zero
        lbl.zPosition = 150
        lbl.alpha     = 0
        cameraNode.addChild(lbl)
        lbl.run(.sequence([
            .fadeIn(withDuration: 0.25),
            .wait(forDuration: 1.0),
            .fadeOut(withDuration: 0.4),
            .removeFromParent()
        ]))
    }

    /// Handles game over state by pausing and updating UI.
    private func triggerGameOver() {
        guard !isPausedByPlayer else { return }
        isPausedByPlayer = true
        joystick.isHidden = true
        joystick.isUserInteractionEnabled = false
        hud.showGameOver()
    }

    // MARK: Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let view else { return }
        
        for touch in touches {
            let loc = touch.location(in: cameraNode)
            let hitNodes = cameraNode.nodes(at: loc)
            
            for node in hitNodes {
                if let nodeName = node.name {
                    switch nodeName {
                    case "buttonA":
                        inputSystem.attackPressed = true
                        // Visual feedback
                        if let button = node as? SKSpriteNode {
                            button.alpha = 0.7
                        }
                        
                    case "buttonB":
                        inputSystem.specialPressed = true
                        // Visual feedback
                        if let button = node as? SKSpriteNode {
                            button.alpha = 0.7
                        }
                        
                    case "pauseButton":
                        togglePause()
                        
                    case "resumeButton":
                        togglePause()
                        
                    case "restartButton", "menuFromGameOver", "menuFromPause":
                        handleMenuNavigation(nodeName: nodeName, view: view)
                        
                    default:
                        break
                    }
                }
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let loc = touch.location(in: cameraNode)
            let hitNodes = cameraNode.nodes(at: loc)
            
            for node in hitNodes {
                if node.name == "buttonA" || node.name == "buttonB" {
                    // Reset button appearance
                    if let button = node as? SKSpriteNode {
                        button.alpha = 1.0
                    }
                }
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Reset button states if touches are cancelled
        inputSystem.attackPressed = false
        inputSystem.specialPressed = false
        
        // Reset button appearances
        if let cameraNode = cameraNode {
            let buttons = cameraNode.children.filter { $0.name == "buttonA" || $0.name == "buttonB" }
            for button in buttons {
                (button as? SKSpriteNode)?.alpha = 1.0
            }
        }
    }

    // MARK: Navigation Helpers
    
    private func handleMenuNavigation(nodeName: String, view: SKView) {
        let savedCoins = playerEntity.get(PlayerComponent.self)?.coins ?? 0
        UserDefaults.standard.set(savedCoins, forKey: "totalCoins")
        
        let nextScene: SKScene
        if nodeName == "menuFromGameOver" || nodeName == "menuFromPause" {
            nextScene = MenuScene(size: size)
        } else { // restartButton
            nextScene = GameScene(size: size)
        }
        
//        nextScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        nextScene.scaleMode = self.scaleMode
        view.presentScene(nextScene, transition: .fade(withDuration: 0.4))
    }

    // MARK: Helpers
    private var lastUpdateTime: TimeInterval = 0
}
