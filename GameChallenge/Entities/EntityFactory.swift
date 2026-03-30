//
//  EntityFactory.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 11/03/26.
//

// MARK: - EntityFactory
// Builds fully-composed entities with their SKSpriteNode visuals.
//
// ╔══════════════════════════════════════════════════════════╗
// ║              ASSET NAMES — EDIT HERE                     ║
// ╠══════════════════════════════════════════════════════════╣
// ║  player_down_1-4   → player walking down (4 frames)      ║
// ║  player_up_1-4     → player walking up (4 frames)        ║
// ║  player_left_1-4   → player walking left (4 frames)      ║
// ║  player_right_1-4  → player walking right (4 frames)     ║
// ║  player_attack_1-6 → player attack animation (6 frames)  ║
// ║  enemy_weak        → small enemy     (28×28 px)          ║
// ║  enemy_normal      → medium enemy    (44×44 px)          ║
// ║  enemy_strong      → large enemy     (64×64 px)          ║
// ║  coin_sprite       → collectible coin (20×20 px)         ║
// ╚══════════════════════════════════════════════════════════╝

import SpriteKit
import Foundation

// MARK: - Asset name constants (change here to rename assets)
enum AssetName {
    static let playerDown   = "adv_run_down_"
    static let playerUp     = "adv_run_up_"
    static let playerLeft   = "adv_run_left_"
    static let playerRight  = "adv_run_right_"
    
    // Idle (um sprite por direção)
    static let playerIdleDown  = "adv_idle_down"
    static let playerIdleUp    = "adv_idle_up"
    static let playerIdleLeft  = "adv_idle_left"
    static let playerIdleRight = "adv_idle_right"
    
    // Ataque direcional (botão A)
    static let playerAtkDown  = "adv_atk_down_"
    static let playerAtkUp    = "adv_atk_up_"
    static let playerAtkLeft  = "adv_atk_left_"
    static let playerAtkRight = "adv_atk_right_"
    
    // Ataque especial (botão B — omnidirecional)
    //    static let playerAttack = "player_attack_"
    
    static let enemyWeak   = "enemy_weak"
    static let enemyNormal = "enemy_normal"
    static let enemyStrong = "enemy_strong"
    static let coin        = "coin_sprite"
    static let box         = "box_sprite"
    
    // MARK: - Enemy sprites
    // ─────────────────────────────────────────────────────────────────
    // Para adicionar um novo tipo de inimigo no futuro:
    // 1. Adicione um novo EnemyAsset abaixo seguindo o mesmo padrão
    // 2. Adicione o novo caso em EnemyComponent.EnemyType
    // 3. Em makeEnemy(), adicione o novo case no switch de `assetConfig`
    // ─────────────────────────────────────────────────────────────────
    struct EnemyAsset {
        let flyBase:   String; let flyCount:   Int
        let dmgBase:   String; let dmgCount:   Int
        let deathBase: String; let deathCount: Int
    }
    
    static let bix = EnemyAsset(
        flyBase:   "bix_fly_",   flyCount:   4,
        dmgBase:   "bix_dmg_",   dmgCount:   3,
        deathBase: "bix_die_",   deathCount: 3
    )
    
    // Em AssetName, adicione:
    static let bixShooter = EnemyAsset(
        flyBase:   "bix_fly_",   flyCount:   4,
        dmgBase:   "bix_dmg_",   dmgCount:   3,
        deathBase: "bix_die_",   deathCount: 3
    )
    static let bixBoss = EnemyAsset(
        flyBase:   "bix_fly_",   flyCount:   4,
        dmgBase:   "bix_dmg_",   dmgCount:   3,
        deathBase: "bix_die_",   deathCount: 3
    )
    
    static let skeleton = EnemyAsset(
        flyBase:   "skeleton_walk_",    flyCount:   10,
        dmgBase:   "skeleton_damage_",  dmgCount:   5,
        deathBase: "skeleton_die_",     deathCount: 12
    )
    
    // Assets extras do skeleton (atk não existe no EnemyAsset padrão)
    static let skeletonAtkBase  = "skeleton_atk_"
    static let skeletonAtkCount = 10
    
    static let yellowSkeletonAtkBase  = "yellowSkeleton_atk_"
    static let yellowSkeletonAtkCount = 10
}

class EntityFactory {
    
    // MARK: Player
    static func makePlayer(at position: CGPoint, scene: SKScene) -> Entity {
        let entity = Entity()
        
        let downTextures  = loadTextures(baseName: AssetName.playerDown,  count: 8)
        let upTextures    = loadTextures(baseName: AssetName.playerUp,    count: 8)
        let leftTextures  = loadTextures(baseName: AssetName.playerLeft,  count: 8)
        let rightTextures = loadTextures(baseName: AssetName.playerRight, count: 8)
        
        // Idle — um frame por direção (fallback para o primeiro frame do run se não existir)
        let idleDown  = loadSingleTexture(AssetName.playerIdleDown)  ?? downTextures[0]
        let idleUp    = loadSingleTexture(AssetName.playerIdleUp)    ?? upTextures[0]
        let idleLeft  = loadSingleTexture(AssetName.playerIdleLeft)  ?? leftTextures[0]
        let idleRight = loadSingleTexture(AssetName.playerIdleRight) ?? rightTextures[0]
        
        // Ataque direcional
        let atkDown  = loadTextures(baseName: AssetName.playerAtkDown,  count: 4)
        let atkUp    = loadTextures(baseName: AssetName.playerAtkUp,    count: 4)
        let atkLeft  = loadTextures(baseName: AssetName.playerAtkLeft,  count: 4)
        let atkRight = loadTextures(baseName: AssetName.playerAtkRight, count: 4)
        
        let spinTextures = [
            atkDown[0],  // Olhando pra baixo
            atkRight[0], // Gira pra direita
            atkUp[0],    // Gira pra cima
            atkLeft[0],
            atkDown[1],  // Olhando pra baixo
            atkRight[1], // Gira pra direita
            atkUp[1],    // Gira pra cima
            atkLeft[1], // Gira pra esquerda
        ]
        
        // Especial (mantém o genérico)
        //        let specialTextures = loadTextures(baseName: AssetName.playerAttack, count: 4)
        
        let node = SKSpriteNode(texture: idleDown)
        node.size      = CGSize(width: 35, height: 75)
        node.position  = position
        node.zPosition = 7
        scene.addChild(node)
        
        entity.add(TransformComponent(node: node))
        entity.add(HealthComponent(max: 100))
        entity.add(MovementComponent(speed: 240))
        entity.add(PlayerComponent())
        entity.add(InputComponent())
        entity.add(AttackComponent(damage: 24, range: 110, cooldown: 0.4))
        //  dano melee: 18  → weak morre em ~2 hits, boss em ~17 hits
        //  especial vira 18 * 20 = 360 → ainda poderoso, mas não quebra o jogo
        entity.add(SpriteComponent(
            downTextures: downTextures, upTextures: upTextures,
            leftTextures: leftTextures, rightTextures: rightTextures,
            idleDown: idleDown, idleUp: idleUp,
            idleLeft: idleLeft, idleRight: idleRight,
            attackDownTextures: atkDown, attackUpTextures: atkUp,
            attackLeftTextures: atkLeft, attackRightTextures: atkRight,
            attackTextures: spinTextures
        ))
        
        return entity
    }
    
    // Carrega um único asset, retorna nil se não existir
    private static func loadSingleTexture(_ name: String) -> SKTexture? {
        guard let image = UIImage(named: name) else { return nil }
        let t = SKTexture(image: image)
        t.filteringMode = .nearest
        return t
    }
    
    // MARK: Enemy
    static func makeEnemy(type: EnemyComponent.EnemyType, at position: CGPoint, scene: SKScene) -> Entity {
        let entity = Entity()
        
        // ── Asset config por tipo ───────────────────────────────────────────
        // Para um novo tipo: adicione o case aqui apontando para seu EnemyAsset
        let asset: AssetName.EnemyAsset
        let spriteSize: CGSize
        switch type {
        case .weak:
            // Skeleton usa SkeletonSpriteComponent — fluxo diferente dos outros
            let walkTextures = loadTextures(baseName: "skeleton_walk_",   count: 10)
            let atkTextures  = loadTextures(baseName: "skeleton_atk_",    count: 10)
            let dmgTextures  = loadTextures(baseName: "skeleton_damage_", count: 5)
            let dieTextures  = loadTextures(baseName: "skeleton_die_",    count: 12)
            
            let skeletonSize   = CGSize(width: 68, height: 68)
            let node         = SKSpriteNode(texture: walkTextures.first)
            node.size        = skeletonSize
            node.position    = position
            node.zPosition   = 8
            scene.addChild(node)
            
            let barWidth: CGFloat  = skeletonSize.width * 1.2
            let barHeight: CGFloat = 5
            let barBg = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 2)
            barBg.fillColor   = UIColor(white: 0.2, alpha: 0.85)
            barBg.strokeColor = .clear
            barBg.position    = CGPoint(x: 0, y: skeletonSize.height / 2 + 8)
            barBg.zPosition   = 1
            node.addChild(barBg)
            
            let barFill = SKShapeNode(rectOf: CGSize(width: barWidth - 2, height: barHeight - 2), cornerRadius: 1.5)
            barFill.fillColor   = .green
            barFill.strokeColor = .clear
            barFill.zPosition   = 1
            barBg.addChild(barFill)
            
            let health = HealthComponent(max: EnemyComponent.EnemyType.weak.maxHealth)
            health.healthBarBackground = barBg
            health.healthBarFill       = barFill
            
            entity.add(TransformComponent(node: node))
            entity.add(health)
            entity.add(MovementComponent(speed: EnemyComponent.EnemyType.weak.speed))
            entity.add(EnemyComponent(type: .weak))
            entity.add(SkeletonSpriteComponent(
                walkTextures: walkTextures,
                atkTextures:  atkTextures,
                dmgTextures:  dmgTextures,
                dieTextures:  dieTextures
            ))
            
//            let debugCircle = SKShapeNode(circleOfRadius: type.radius)
//                    debugCircle.strokeColor = .red
//                    debugCircle.fillColor = .red.withAlphaComponent(0.2) // Um vermelho clarinho pra ver a área
//                    debugCircle.lineWidth = 4
//                    debugCircle.zPosition = 1000 // Joga pro topo de tudo no mundo
//                    debugCircle.name = "debugHitbox"
//                    node.addChild(debugCircle)
            
            
            return entity  // ← retorno antecipado, sai do switch
        case .normal:
            return makeYellowSkeletonEnemy(at: position, scene: scene)
        case .strong:
            asset      = AssetName.bix          // ← troque por AssetName.seuNovoInimigo quando tiver
            spriteSize = CGSize(width: 88, height: 88)
        case .shooter:
            asset      = AssetName.bixShooter
            spriteSize = CGSize(width: 58, height: 58)
        case .boss:
            asset      = AssetName.bixBoss
            spriteSize = CGSize(width: 200, height: 200)  // ← escala maior
            
        }
        
        // ── Carrega texturas ────────────────────────────────────────────────
        let flyTextures   = loadTextures(baseName: asset.flyBase,   count: asset.flyCount)
        let dmgTextures   = loadTextures(baseName: asset.dmgBase,   count: asset.dmgCount)
        let deathTextures = loadTextures(baseName: asset.deathBase, count: asset.deathCount)
        
        // ── Nó principal ────────────────────────────────────────────────────
        let node = SKSpriteNode(texture: flyTextures.first)
        node.size      = spriteSize
        node.position  = position
        node.zPosition = 7
        scene.addChild(node)
        
        // ── Tint por tipo ────────────────────────────────────────────────────
        // se quiser colorir os bixo
        //        switch type {
        //        case .strong:
        //            node.color            = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1)
        //            node.colorBlendFactor = 0.75
        //        case .shooter:
        //            node.color            = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1)
        //            node.colorBlendFactor = 0.75
        //        default:
        //            break
        //        }
        
        // ── Health bar ──────────────────────────────────────────────────────
        let barWidth: CGFloat  = spriteSize.width * 1.2
        let barHeight: CGFloat = 5
        let barBg = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 2)
        barBg.fillColor   = UIColor(white: 0.2, alpha: 0.85)
        barBg.strokeColor = .clear
        barBg.position    = CGPoint(x: 0, y: spriteSize.height / 2 + 8)
        barBg.zPosition   = 1
        node.addChild(barBg)
        
        let barFill = SKShapeNode(rectOf: CGSize(width: barWidth - 2, height: barHeight - 2), cornerRadius: 1.5)
        barFill.fillColor   = .green
        barFill.strokeColor = .clear
        barFill.zPosition   = 1
        barBg.addChild(barFill)
        
        // ── Componentes ─────────────────────────────────────────────────────
        let health = HealthComponent(max: type.maxHealth)
        health.healthBarBackground = barBg
        health.healthBarFill       = barFill
        
        entity.add(TransformComponent(node: node))
        entity.add(health)
        entity.add(MovementComponent(speed: type.speed))
        entity.add(EnemyComponent(type: type))
        entity.add(EnemySpriteComponent(
            flyTextures:   flyTextures,
            dmgTextures:   dmgTextures,
            deathTextures: deathTextures
        ))
        
        return entity
    }
    
    // MARK: YellowSkeleton (normal) — pipeline separado
    private static func makeYellowSkeletonEnemy(at position: CGPoint, scene: SKScene) -> Entity {
        let entity     = Entity()
        let type       = EnemyComponent.EnemyType.normal
        let spriteSize = CGSize(width: 68, height: 68)   // ← mesmo tamanho do .normal anterior
        
        let walkTextures = loadTextures(baseName: "yellowSkeleton_walk_",   count: 10)
        let atkTextures  = loadTextures(baseName: "yellowSkeleton_atk_",    count: 10)
        let dmgTextures  = loadTextures(baseName: "yellowSkeleton_damage_", count: 5)
        let dieTextures  = loadTextures(baseName: "yellowSkeleton_die_",    count: 12)
        
        let node = SKSpriteNode(texture: walkTextures.first)
        node.size      = spriteSize
        node.position  = position
        node.zPosition = 7
        scene.addChild(node)
        
        let barWidth: CGFloat  = spriteSize.width * 1.2
        let barHeight: CGFloat = 5
        let barBg = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 2)
        barBg.fillColor   = UIColor(white: 0.2, alpha: 0.85)
        barBg.strokeColor = .clear
        barBg.position    = CGPoint(x: 0, y: spriteSize.height / 2 + 8)
        barBg.zPosition   = 1
        node.addChild(barBg)
        
        let barFill = SKShapeNode(rectOf: CGSize(width: barWidth - 2, height: barHeight - 2), cornerRadius: 1.5)
        barFill.fillColor   = .green
        barFill.strokeColor = .clear
        barFill.zPosition   = 1
        barBg.addChild(barFill)
        
        let health = HealthComponent(max: type.maxHealth)
        health.healthBarBackground = barBg
        health.healthBarFill       = barFill
        
        entity.add(TransformComponent(node: node))
        entity.add(health)
        entity.add(MovementComponent(speed: type.speed))
        entity.add(EnemyComponent(type: type))
        entity.add(SkeletonSpriteComponent(
            walkTextures: walkTextures,
            atkTextures:  atkTextures,
            dmgTextures:  dmgTextures,
            dieTextures:  dieTextures
        ))
        return entity
    }
    
    // MARK: Coin
    static func makeCoin(at position: CGPoint, scene: SKScene) -> Entity {
        let entity = Entity()
        
        let node = SKSpriteNode(imageNamed: AssetName.coin)
        node.size      = CGSize(width: 40, height: 40)  // fixed coin size
        node.position  = position
        node.zPosition = 5
        node.run(.repeatForever(.sequence([
            .scale(to: 1.18, duration: 0.55),
            .scale(to: 1.0,  duration: 0.55)
        ])))
        scene.addChild(node)
        
        entity.add(TransformComponent(node: node))
        entity.add(CoinComponent())
        
        return entity
    }
    
    // MARK: Ladder
    static func makeLadder(at position: CGPoint, scene: SKScene) -> Entity {
        let entity = Entity()
        
        let node = SKSpriteNode(imageNamed: "ladder_sprite")
        node.size      = CGSize(width: 124, height: 124)   // ← ajuste ao tamanho do asset
        node.position  = position
        node.zPosition = 6
        node.alpha     = 0
        
        scene.addChild(node)
        
        node.run(.fadeIn(withDuration: 0.5))
        
        entity.add(TransformComponent(node: node))
        entity.add(LadderComponent())
        
        return entity
    }
    
    // MARK: Arrow (indicador de direção)
    static func makeArrow(attachedTo cameraNode: SKCameraNode) -> SKSpriteNode {
        let node = SKSpriteNode(imageNamed: "arrow_sprite")
        node.size      = CGSize(width: 32, height: 32)
        node.zPosition = 20
        node.alpha     = 0
        node.run(.fadeIn(withDuration: 0.3))
        node.run(.repeatForever(.sequence([
            .scale(to: 1.2, duration: 0.4),
            .scale(to: 1.0, duration: 0.4)
        ])))
        
        // Filha do cameraNode — sempre visível na tela
        cameraNode.addChild(node)
        return node
    }
    
    // MARK: Consumables
    static func makeConsumable(type: ItemComponent.ItemType, at position: CGPoint, scene: SKScene) -> Entity{
        
        let entity = Entity()
        
        let node = SKSpriteNode()
        
        switch type {
        case .healthPotion:
            let textures = [
                SKTexture(imageNamed: "green_crystal_0000"),
                SKTexture(imageNamed: "green_crystal_0001"),
                SKTexture(imageNamed: "green_crystal_0002"),
                SKTexture(imageNamed: "green_crystal_0003")
            ]
            
            node.texture = textures[0]
            
            let animateFrames = SKAction.animate(with: textures, timePerFrame: 0.15)
            
            node.run(.repeatForever(animateFrames))
        case .specialCharge:
            let textures = [
                SKTexture(imageNamed: "blue_crystal_0000"),
                SKTexture(imageNamed: "blue_crystal_0001"),
                SKTexture(imageNamed: "blue_crystal_0002"),
                SKTexture(imageNamed: "blue_crystal_0003")
            ]
            
            node.texture = textures[0]
            
            let animateFrames = SKAction.animate(with: textures, timePerFrame: 0.15)
            
            node.run(.repeatForever(animateFrames))
        case .killAll:
            let textures = [
                SKTexture(imageNamed: "purple_crystal_0000"),
                SKTexture(imageNamed: "purple_crystal_0001"),
                SKTexture(imageNamed: "purple_crystal_0002"),
                SKTexture(imageNamed: "purple_crystal_0003")
            ]
            
            node.texture = textures[0]
            
            let animateFrames = SKAction.animate(with: textures, timePerFrame: 0.15)
            
            node.run(.repeatForever(animateFrames))
            
        case .shuriken:
            let textures = [
                SKTexture(imageNamed: "joystick_shuriken")
            ]
            
            node.texture = textures[0]
        }
        
        node.size = CGSize(width: 40, height: 40)
        node.position = position
        node.zPosition = 5
        scene.addChild(node)
        
        entity.add(TransformComponent(node: node))
        
        // common (health) = 0.2, uncommon (special) = 0.1, rare (killAll) = 0.02
        let rarity: CGFloat
        switch type {
        case .healthPotion:
            rarity = 0.2
        case .specialCharge:
            rarity = 0.1
        case .killAll:
            rarity = 0.02
        case .shuriken:
            rarity = 0.4
        }
        
        entity.add(ItemComponent(type: type, rarity: rarity))
        
        return entity
    }
    
    // MARK: - Helper Methods
    
    /// Loads a sequence of textures with a base name and count
    /// Example: loadTextures(baseName: "player_down_", count: 4) loads player_down_1, player_down_2, etc.
    private static func loadTextures(baseName: String, count: Int) -> [SKTexture] {
        var textures: [SKTexture] = []
        
        for i in 1...count {
            let textureName = "\(baseName)\(i)"
            
            // Try to load the texture
            if let texture = UIImage(named: textureName) {
                let realTexture = SKTexture(image: texture)
                realTexture.filteringMode = .nearest
                textures.append(realTexture)
            } else {
                // Fallback: create a colored rectangle for missing textures
                print("Warning: Could not load texture \(textureName) - using fallback")
                let fallbackTexture = createFallbackTexture(index: i, baseName: baseName)
                textures.append(fallbackTexture)
            }
        }
        
        return textures
    }
    
    /// Creates a fallback colored texture for missing assets
    private static func createFallbackTexture(index: Int, baseName: String) -> SKTexture {
        let size = CGSize(width: 68, height: 68)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { ctx in
            // Different colors for different animation frames to make them visible
            let color: UIColor
            if baseName.contains("attack") {
                color = .red.withAlphaComponent(0.7)
            } else if baseName.contains("down") {
                color = .blue.withAlphaComponent(0.5 + CGFloat(index) * 0.1)
            } else if baseName.contains("up") {
                color = .green.withAlphaComponent(0.5 + CGFloat(index) * 0.1)
            } else if baseName.contains("left") {
                color = .yellow.withAlphaComponent(0.5 + CGFloat(index) * 0.1)
            } else if baseName.contains("right") {
                color = .orange.withAlphaComponent(0.5 + CGFloat(index) * 0.1)
            } else {
                color = .purple
            }
            
            // Draw colored rectangle
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            
            // Draw frame number for debugging
            let text = "\(index)"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 20),
                .foregroundColor: UIColor.white
            ]
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            text.draw(in: textRect, withAttributes: attributes)
        }
        
        return SKTexture(image: image)
    }
    
    // MARK: Box
    /// Spawns um obstáculo indestructível aleatório na posição dada.
    /// Para adicionar novos tipos: basta adicionar um case em BoxComponent.ObstacleType.
    static func makeBox(at position: CGPoint, scene: SKScene) -> Entity {
        let entity = Entity()
        
        // Sorteia aleatoriamente um dos tipos disponíveis
        let obstacleType = BoxComponent.ObstacleType.allCases.randomElement()!
        
        let node = SKSpriteNode(imageNamed: obstacleType.assetName)
        node.size      = CGSize(width: 50, height: 50)
        node.position  = position
        node.zPosition = 5
        scene.addChild(node)
        
        if let anim = obstacleType.loopAnimation {
            node.run(anim)
        }
        
        let barWidth: CGFloat  = node.size.width * 1.2
        let barHeight: CGFloat = 5
        let barBg = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 2)
        barBg.fillColor   = UIColor(white: 0.2, alpha: 0.85)
        barBg.strokeColor = .clear
        barBg.position    = CGPoint(x: 0, y: node.size.height / 2 + 8)
        barBg.zPosition   = 1
        barBg.alpha       = 0 // Começa invisível
        node.addChild(barBg)
        
        let barFill = SKShapeNode(rectOf: CGSize(width: barWidth - 2, height: barHeight - 2), cornerRadius: 1.5)
        barFill.fillColor   = .green
        barFill.strokeColor = .clear
        barFill.zPosition   = 1
        barBg.addChild(barFill)
        
        let health = HealthComponent(max: EnemyComponent.EnemyType.weak.maxHealth)
        health.healthBarBackground = barBg
        health.healthBarFill       = barFill
        
        entity.add(TransformComponent(node: node))
        entity.add(BoxComponent(type: obstacleType))
        entity.add(health)
        
        return entity
    }
    
    // MARK: Projectile (player) — knife animation
    static func makeProjectile(at position: CGPoint, direction: CGVector, scene: SKScene, target: Entity? = nil) -> Entity {
        let entity = Entity()
        
        let textures = loadTextures(baseName: "Shuriken_2_", count: 30)
        
        let node = SKSpriteNode(texture: textures.first)
        node.size      = CGSize(width: 32, height: 32)  // ← ajuste ao tamanho do sprite
        node.position  = position
        node.zPosition = 9
        
        node.zRotation = atan2(direction.dy, direction.dx) - (.pi / 2)
        
        scene.addChild(node)
        
        // Animação em loop enquanto voa
        let animate = SKAction.animate(with: textures, timePerFrame: 0.04)  // ← ajuste a velocidade
        node.run(.repeatForever(animate))
        
        entity.add(TransformComponent(node: node))
        entity.add(ProjectileComponent(damage: 12, direction: direction, speed: 600, target: target ?? Entity()))
        //  ligeiramente abaixo do melee — tiro é mais seguro, então faz menos dano
        
        SoundManager.shared.play(SoundManager.shared.attack2, on: node)
        
        return entity
    }
    
    // MARK: EnemyProjectile — fireball animation
    static func makeEnemyProjectile(at position: CGPoint, direction: CGVector, scene: SKScene) -> Entity {
        let entity = Entity()
        
        let textures = loadTextures(baseName: "fireball_", count: 5)
        
        let node = SKSpriteNode(texture: textures.first)
        node.size      = CGSize(width: 48, height: 48)  // ← ajuste ao tamanho do sprite
        node.position  = position
        node.zPosition = 9
        
        // Rotaciona o sprite na direção do tiro
        node.zRotation = atan2(direction.dy, direction.dx) - (.pi / 2)
        
        scene.addChild(node)
        SoundManager.shared.play(SoundManager.shared.flameShot, on: node)
        
        // Animação em loop enquanto voa
        let animate = SKAction.animate(with: textures, timePerFrame: 0.1)  // ← ajuste a velocidade
        node.run(.repeatForever(animate))
        
        entity.add(TransformComponent(node: node))
        entity.add(ProjectileComponent(damage: 10, direction: direction, speed: 380, target: Entity()))
        //  era 12, desce pra 10 — fireball é mais lenta, justo ser um pouco mais fraca
        
        return entity
    }}

func makeSpinAttackAction(spriteComponent: SpriteComponent) -> SKAction {
    // Pegamos o primeiro frame de cada direção para dar a sensação de giro rápido
    // Ou você pode usar todos os frames de cada direção se quiser um giro mais lento
    
    let frameR = spriteComponent.attackRightTextures.first!
    let frameU = spriteComponent.attackUpTextures.first!
    let frameL = spriteComponent.attackLeftTextures.first!
    let frameD = spriteComponent.attackDownTextures.first!
    
    // Criamos a sequência de troca de texturas
    let spinTextures = [frameR, frameU, frameL, frameD]
    
    // Cada frame dura bem pouquinho para o giro parecer fluido
    let animateSpin = SKAction.animate(with: spinTextures, timePerFrame: 0.07)
    
    // Podemos repetir o giro 2 vezes para ficar mais impactante
    return SKAction.repeat(animateSpin, count: 2)
}

