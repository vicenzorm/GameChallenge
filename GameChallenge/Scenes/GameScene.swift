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
    private var boxEntities: [Entity] = []
    private var projectileEntities: [Entity] = []
    private var dyingEnemies: [Entity] = []
    private var itemEntities: [Entity] = []
    private var enemyProjectileEntities: [Entity] = []
    private var ladderEntity:  Entity?
    
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
    private let boxSystem        = BoxSystem()
    private let projectileSystem = ProjectileSystem()
    private let enemySystem = EnemySystem()
    private let itemSpawnSystem = ItemSpawnSystem()
    
    // MARK: UI
    private var hud:        HUD!
    private var cameraNode: SKCameraNode!
    private var movementJoystick: Joystick!
    private var attackJoystick:   Joystick!
    
    // Cutscene (retido aqui para não ser desalocado durante o vídeo)
    private var cutscenePlayer: CutscenePlayer?
    
    // Pause state
    private var isPausedByPlayer = false
    // private var pauseNode: Pause!
    
    private var lastCooldownUpdate: TimeInterval = 0
    
    private var arrowNode:     SKSpriteNode?
    private let arrowRadius:   CGFloat = 90   // distância da seta ao redor do player
    
    // World size
    private let worldSize = CGSize(width: 1800, height: 1800)
    
    override init(size: CGSize) {
        //        pauseNode = Pause(size: size)
        super.init(size: size)
        //        addChild(pauseNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Scene entry point: constructs world, camera, UI, player, and wires callbacks.
    override func didMove(to view: SKView) {
        view.isMultipleTouchEnabled = true
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        setupWorld()
        setupCamera()
        setupJoystick()
        setupHUD(view: view)
        setupPlayer()
        setupBoxes()
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
        let bg = SKSpriteNode(imageNamed: kBackgroundAsset)
        bg.size      = worldSize
        bg.position  = .zero   // anchorPoint 0.5,0.5 → centrado na origem
        bg.zPosition = -10
        addChild(bg)
        
        // Borda visual opcional — remove se não quiser
        let border = SKShapeNode(rectOf: worldSize)
        border.strokeColor = UIColor(white: 0.4, alpha: 0.6)
        border.fillColor   = .clear
        border.lineWidth   = 4
        border.zPosition   = -5
        addChild(border)
    }
    
    /// Mantém a câmera dentro dos limites do mundo para não mostrar além do background.
    private func clampCamera() {
        guard let view = self.view else { return }
        
        // Metade do que a câmera enxerga na tela (em pontos do mundo)
        let visibleHalfW = view.bounds.width  / 2
        let visibleHalfH = view.bounds.height / 2
        
        // Limites: a câmera não pode ir além de onde o background acaba
        let minX = -worldSize.width  / 2 + visibleHalfW
        let maxX =  worldSize.width  / 2 - visibleHalfW
        let minY = -worldSize.height / 2 + visibleHalfH
        let maxY =  worldSize.height / 2 - visibleHalfH
        
        var camPos = cameraNode.position
        
        // Se o mundo for menor que a tela num eixo, centraliza naquele eixo
        if minX > maxX { camPos.x = 0 } else { camPos.x = camPos.x.clamped(to: minX...maxX) }
        if minY > maxY { camPos.y = 0 } else { camPos.y = camPos.y.clamped(to: minY...maxY) }
        
        cameraNode.position  = camPos
        //        pauseNode.position   = camPos
    }
    
    /// Creates and adds the camera node, setting its zPosition and linking it to the scene.
    private func setupCamera() {
        cameraNode          = SKCameraNode()
        cameraNode.zPosition = 50
        addChild(cameraNode)
        camera = cameraNode
    }
    
    func addItemEntity(_ entity: Entity) {
        itemEntities.append(entity)
    }
    
    /// Initializes the joystick, adds it to the camera, and makes it visible and interactive.
    private func setupJoystick() {
        movementJoystick = Joystick()
        cameraNode.addChild(movementJoystick)
        movementJoystick.isUserInteractionEnabled = true
        
        attackJoystick = Joystick()
        cameraNode.addChild(attackJoystick)
        attackJoystick.isUserInteractionEnabled = true
        
        layoutJoystick()
    }
    
    /// Positions the joystick in the bottom-left of the camera's visible area.
    /// Safe to call multiple times (e.g., on rotation/resize). No-ops if scene/joystick not ready.
    private func layoutJoystick() {
        guard let movementJoystick = movementJoystick,
              let attackJoystick = attackJoystick,
              let scene = self.scene ?? self as SKScene? else { return }
        let margin: CGFloat = 80
        // Scene size represents the camera's visible rect when camera is centered and scaleMode applied
        let width  = scene.size.width
        let height = scene.size.height
        // Convert to camera's local coordinate space: camera's origin is its center
        movementJoystick.position = CGPoint(x: -width/2 + margin, y: -height/2 + margin)
        attackJoystick.position = CGPoint(x: width/2 - margin, y: -height/2 + margin)
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
            guard let self else { return }
            self.hud.updateWave(wave)
            self.showWaveBanner(wave: wave)
            self.reshuffleBoxes()
            
            if wave > 1 {
                self.removeLadderAndArrow()
            }
        }
        
        waveSystem.onWaveEnd = { [weak self] completedWave in
            guard let self else { return }
            
            // Delay antes de spawnar a escada
            self.run(.wait(forDuration: 1.5)) { [weak self] in
                guard let self else { return }
                self.spawnLadder()
            }
        }
    }
    
    /// Scatters indestructible boxes randomly around the world, keeping the centre clear.
    private func setupBoxes() {
        let count      = 40          // tweak to taste
        let margin: CGFloat = 100    // min distance from world edge
        let clearRadius: CGFloat = 200  // spawn-free zone around the player start (0,0)
        
        var placed = 0
        var attempts = 0
        let maxAttempts = count * 10
        
        while placed < count && attempts < maxAttempts {
            attempts += 1
            let x = CGFloat.random(in: -worldSize.width  / 2 + margin ... worldSize.width  / 2 - margin)
            let y = CGFloat.random(in: -worldSize.height / 2 + margin ... worldSize.height / 2 - margin)
            let pos = CGPoint(x: x, y: y)
            
            // Keep the player start area clear
            guard hypot(pos.x, pos.y) > clearRadius else { continue }
            
            boxEntities.append(EntityFactory.makeBox(at: pos, scene: self))
            placed += 1
        }
    }
    
    /// Removes all current boxes and spawns a fresh random layout.
    func reshuffleBoxes() {
        // Remove existing box nodes from the scene
        for box in boxEntities {
            box.get(TransformComponent.self)?.node.removeFromParent()
        }
        boxEntities.removeAll()
        
        // Spawn a new layout using the same logic as setupBoxes()
        setupBoxes()
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
        
        if currentTime - lastCooldownUpdate > 1 {
            lastCooldownUpdate = currentTime
            hud.updateContinueCooldown()
        }
        
        guard !isPausedByPlayer else { return }
        let dt = calculateDeltaTime(currentTime)
        
        // 1. Get joystick input
        let movementVelocity = movementJoystick.velocity
        let attackVelocity = attackJoystick.velocity
        
        inputSystem.update(playerEntity: playerEntity,
                           movementDirection: movementVelocity,
                           attackDirection: attackVelocity)
        
        // 2. Player
        playerSystem.update(
            playerEntity:    playerEntity,
            motionDirection: CGVector(dx: movementVelocity.x, dy: movementVelocity.y),
            deltaTime:       dt,
            currentTime:     currentTime
        )
        
        // 3. Enemy AI
        enemyAISystem.update(
            enemies: enemyEntities,
            playerEntity: playerEntity,
            deltaTime: dt,
            currentTime: currentTime,
            onEnemyShoot: { [weak self] enemy, direction in
                guard let self,
                      let pos = enemy.get(TransformComponent.self)?.node.position
                else { return }
                let proj = EntityFactory.makeEnemyProjectile(at: pos, direction: direction, scene: self)
                self.enemyProjectileEntities.append(proj)
            }
        )
        
        // 4. Movement system moves all dynamic entities (player + enemies) using velocity/acceleration from components
        movementSystem.update(entities: [playerEntity!] + enemyEntities, deltaTime: dt)
        
        // 4b. Box collision — push movers out of indestructible boxes
        boxSystem.update(movers: [playerEntity!] + enemyEntities, boxes: boxEntities)
        
        // 4c. Atualiza seta indicadora de direção da escada
        updateArrow()
        
        // 5. Camera follows player — clamped to world bounds
        if let node = playerEntity.get(TransformComponent.self)?.node {
            cameraNode.position = node.position
            clampCamera()   // ← aplica o clamp depois de seguir o player
        }
        
        // 6. Attack & Shooting
        if let attack = playerEntity.get(AttackComponent.self), let pl = playerEntity.get(PlayerComponent.self) {

            // Ataque corpo a corpo (Botão A) — só executa se isAttacking está ativo
            if attack.isAttacking {
                let isSpecialNow = playerEntity.get(SpriteComponent.self)?.isSpecialAttack ?? false
                attackSystem.update(
                    attackerEntity: playerEntity,
                    enemies: enemyEntities,
                    scene: self,
                    isSpecial: isSpecialNow,
                    enemySystem: enemySystem
                )
                if !isSpecialNow { hud.flashButtonA() }
            }

            if inputSystem.specialPressed && pl.specialReady {
                inputSystem.specialPressed = false

                attackSystem.startSpecialAttack(
                    player: playerEntity,
                    enemies: enemyEntities,
                    scene: self,
                    enemySystem: enemySystem
                )

                // Zera a barra no componente e no HUD
                pl.killStreak = 0
                pl.specialReady = false
                hud.updateSpecial(killStreak: 0, isReady: false)
            }

            // Tiro (Joystick direito)
            if attack.wantsToShoot {
                attack.wantsToShoot = false
                if let pos = playerEntity.get(TransformComponent.self)?.node.position {
                    let projectile = EntityFactory.makeProjectile(
                        at: pos,
                        direction: attack.shootDirection,
                        scene: self
                    )
                    projectileEntities.append(projectile)
                }
            }
        }
        
        // 6.5. Atualiza as balas e remove as destruídas
        let deadProjectiles = projectileSystem.update(
            projectiles: projectileEntities,
            enemies: enemyEntities,
            deltaTime: dt,
            enemySystem: enemySystem
        )
        for proj in deadProjectiles {
            proj.get(TransformComponent.self)?.node.removeFromParent()
        }
        let deadProjIDs = Set(deadProjectiles.map { $0.id })
        projectileEntities.removeAll { deadProjIDs.contains($0.id) }
        
        // 6.6 Projéteis inimigos → causam dano ao player
        let deadEnemyProj = projectileSystem.updateEnemyProjectiles(
            projectiles: enemyProjectileEntities,
            playerEntity: playerEntity,
            deltaTime: dt
        )
        for proj in deadEnemyProj {
            proj.get(TransformComponent.self)?.node.removeFromParent()
        }
        let deadEnemyProjIDs = Set(deadEnemyProj.map { $0.id })
        enemyProjectileEntities.removeAll { deadEnemyProjIDs.contains($0.id) }
        
        // 7. Health bars
        healthSystem.update(entities: enemyEntities)
        
        // 7b
        enemySystem.update(enemies: enemyEntities + dyingEnemies, currentTime: currentTime)
        
        // 8. Enemy → player collision
        collisionSystem.checkEnemyPlayerCollisions(
            playerEntity: playerEntity, enemies: enemyEntities, deltaTime: dt, enemySystem: enemySystem)
        
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
        
        // 9b. Colisão com escada → avança de andar
        if let ladder = ladderEntity,
           let ladderNode = ladder.get(TransformComponent.self)?.node,
           let playerNode = playerEntity.get(TransformComponent.self)?.node {

            if playerNode.position.distance(to: ladderNode.position) < 40 {
                // NÃO zere ladderEntity aqui — advanceFloor → removeLadderAndArrow cuida disso
                advanceFloor()
            }
        }
        
        // 10. Dead enemies
        var killedPts = 0
        let dead = enemyEntities.filter { $0.get(HealthComponent.self)?.isAlive == false }
        for d in dead {
            if let t = d.get(EnemyComponent.self)?.type {
                killedPts += t.specialPoints
                maybeDropCoin(at: d.get(TransformComponent.self)?.node.position ?? .zero)
                maybeDropItem(at: d.get(TransformComponent.self)?.node.position ?? .zero)
            }
            // Para o movimento do inimigo morto
            d.get(MovementComponent.self)?.velocity = .zero
            // Trigga animação — nó será removido pelo EnemySystem ao terminar
            enemySystem.triggerDeath(enemy: d)
            dyingEnemies.append(d)   // ← move para lista de moribundos
        }
        let deadIDs = Set(dead.map { $0.id })
        enemyEntities.removeAll { deadIDs.contains($0.id) }
        
        // Remove da lista de moribundos os que já tiveram o nó removido da cena
        dyingEnemies.removeAll {
            $0.get(TransformComponent.self)?.node.parent == nil
        }
        
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
//        if let pl = playerEntity.get(PlayerComponent.self) { hud.updateCoins(pl.coins) }
        
        // 14. Wave + coin spawn
        if let node = playerEntity.get(TransformComponent.self)?.node {
            waveSystem.update(deltaTime: dt, activeEnemies: enemyEntities.count,
                              sceneSize: worldSize, playerPosition: node.position)
        }
        coinSpawnSystem.update(deltaTime: dt, activeCoins: coinEntities.count, sceneSize: worldSize)
        
        // 15. Item spawn
        itemSpawnSystem.update(
            deltaTime: dt,
            currentTime: currentTime,
            activeItems: itemEntities.count,
            sceneSize: worldSize,
            scene: self
        )
        
        // 16. Item collection (Coleta)
        // Reutilizamos a lógica de distância das moedas para os itens
        let pickedItems = collisionSystem.checkCoinCollection(playerEntity: playerEntity, coins: itemEntities)
        for item in pickedItems {
            collisionSystem.handleItemPickup(player: playerEntity, item: item, scene: self)
        }
        
        // Limpeza da lista
        let pickedIDs = Set(pickedItems.map { $0.id })
        itemEntities.removeAll { pickedIDs.contains($0.id) }
        
    }
    
    /// Toggles pause state and updates HUD accordingly.
    func togglePause() {
        isPausedByPlayer.toggle()
        
        // Esconde ou mostra os joysticks baseado no estado de pausa
        movementJoystick.isHidden = isPausedByPlayer
        movementJoystick.isUserInteractionEnabled = !isPausedByPlayer
        
        attackJoystick.isHidden = isPausedByPlayer
        attackJoystick.isUserInteractionEnabled = !isPausedByPlayer
        
        hud.showPauseOverlay(isPausedByPlayer)
    }
    
    private func advanceFloor() {
        // Esconde joysticks durante a cutscene
        movementJoystick.isHidden = true
        attackJoystick.isHidden   = true
        isPausedByPlayer           = true
        
        removeLadderAndArrow()
        
        // Limpa inimigos restantes (edge case)
        for e in enemyEntities {
            e.get(TransformComponent.self)?.node.removeFromParent()
        }
        enemyEntities.removeAll()
        
        guard let view = self.view else { return }
        
        let cp = CutscenePlayer()
        cutscenePlayer = cp
        cp.play(wave: waveSystem.currentWave, over: view) { [weak self] in
            guard let self else { return }
            self.cutscenePlayer          = nil
            self.isPausedByPlayer        = false
            self.movementJoystick.isHidden = false
            self.attackJoystick.isHidden   = false
            self.waveSystem.startNextWave(sceneSize: self.worldSize)
        }
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
    
    /// Randomly drops a consumable at the specified position.
    /// Tweak `dropChance` to make consumables more/less frequent on enemy kill.
    private func maybeDropItem(at pos: CGPoint) {
        let dropChance: CGFloat = 0.10
        guard CGFloat.random(in: 0...1) < dropChance else { return }
        
        // Weighted random by desirability/rarity.
        let roll = CGFloat.random(in: 0...1)
        let type: ItemComponent.ItemType
        if roll < 0.05 { type = .killAll }
        else if roll < 0.15 { type = .specialCharge }
        else { type = .healthPotion }
        
        let item = EntityFactory.makeConsumable(type: type, at: pos, scene: self)
        addItemEntity(item)
    }
    
    /// Displays a wave banner at the center of the screen.
    private func showWaveBanner(wave: Int) {
        let lbl = SKLabelNode(text: "FLOOR \(wave)")
        lbl.fontName  = AppManager.shared.secondaryFont
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
        movementJoystick.isHidden = true
        movementJoystick.isUserInteractionEnabled = false
        attackJoystick.isHidden = true
        attackJoystick.isUserInteractionEnabled = false
        hud.showGameOver()
    }
    
    // MARK: - Ladder & Arrow
    
    private func spawnLadder() {
        guard let playerPos = playerEntity.get(TransformComponent.self)?.node.position else { return }

        let margin: CGFloat = 150
        var pos: CGPoint
        repeat {
            let x = CGFloat.random(in: -worldSize.width  / 2 + margin ... worldSize.width  / 2 - margin)
            let y = CGFloat.random(in: -worldSize.height / 2 + margin ... worldSize.height / 2 - margin)
            pos = CGPoint(x: x, y: y)
        } while pos.distance(to: playerPos) < 300

        ladderEntity = EntityFactory.makeLadder(at: pos, scene: self)

        // Passa o cameraNode — seta será filha da câmera
        arrowNode = EntityFactory.makeArrow(attachedTo: cameraNode)
    }
    
    private func removeLadderAndArrow() {
        let ladderNode = ladderEntity?.get(TransformComponent.self)?.node
        ladderEntity   = nil

        ladderNode?.run(.sequence([
            .fadeOut(withDuration: 0.3),
            .removeFromParent()
        ]))

        arrowNode?.removeFromParent()
        arrowNode = nil
    }
    
    /// Atualiza a posição e rotação da seta para apontar para a escada.
    private func updateArrow() {
        guard
            let arrow      = arrowNode,
            let ladderNode = ladderEntity?.get(TransformComponent.self)?.node,
            let playerNode = playerEntity.get(TransformComponent.self)?.node
        else { return }

        let playerPos = playerNode.position
        let ladderPos = ladderNode.position

        let dx    = ladderPos.x - playerPos.x
        let dy    = ladderPos.y - playerPos.y
        let angle = atan2(dy, dx)

        // Como a seta é filha do cameraNode, a posição é relativa ao centro da tela
        arrow.position = CGPoint(
            x: cos(angle) * arrowRadius,
            y: sin(angle) * arrowRadius
        )

        arrow.zRotation = angle - (.pi / 2)
    }
    
    // Made internal so systems (e.g., CollisionSystem) can trigger it.
    func clearEnemiesAroundPlayer() {
        
        for enemy in enemyEntities {
            enemy.get(TransformComponent.self)?.node.run(.sequence([
                .scale(to: 0.1, duration: 0.15),
                .removeFromParent()
            ]))
        }
        
        enemyEntities.removeAll()
    }
    
    private func handleContinue(view: SKView) {
        
        guard let vc = view.window?.rootViewController else {
            print("Não encontrou ViewController")
            return
        }
        
        AdManager.shared.showAd(from: vc) { [weak self] in
            guard let self = self else { return }
            
            print("Player reviveu após anúncio")
            
            // revive o player
            
            if let health = self.playerEntity.get(HealthComponent.self) {
                health.current = health.max
                health.isInvulnerable = true
                
                let sprite = self.playerEntity.get(TransformComponent.self)?.node
                sprite?.alpha = 0.5
                
                self.run(.wait(forDuration: 2.0)) {
                    health.isInvulnerable = false
                    sprite?.alpha = 1.0
                }
            }
            
            // remove game over
            self.hud.hideGameOver()
            
            // retoma jogo
            
            self.clearEnemiesAroundPlayer()
            
            self.hud.hideGameOver()
            self.isPausedByPlayer = false
            
            self.movementJoystick.isHidden = false
            self.movementJoystick.isUserInteractionEnabled = true
            self.attackJoystick.isHidden = false
            self.attackJoystick.isUserInteractionEnabled = true
        }
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
                        
                    case "continueButton":
                        handleContinue(view: view)
                        
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

// MARK: - Comparable clamp helper
private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
