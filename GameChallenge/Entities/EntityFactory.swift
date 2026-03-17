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
        node.zPosition = 6
        scene.addChild(node)

        entity.add(TransformComponent(node: node))
        entity.add(HealthComponent(max: 100))
        entity.add(MovementComponent(speed: 220))
        entity.add(PlayerComponent())
        entity.add(InputComponent())
        entity.add(AttackComponent(damage: 14, range: 70, cooldown: 0.4))
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
            asset      = AssetName.bix
            spriteSize = CGSize(width: 68, height: 68)
        case .normal:
            asset      = AssetName.bix          // ← troque por AssetName.seuNovoInimigo quando tiver
            spriteSize = CGSize(width: 88, height: 88)
        case .strong:
            asset      = AssetName.bix          // ← troque por AssetName.seuNovoInimigo quando tiver
            spriteSize = CGSize(width: 128, height: 128)
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
    
    // MARK: Consumables
    
    static func makeConsumable(type: ItemComponent.ItemType, at position: CGPoint, scene: SKScene) -> Entity{
        
        let entity = Entity()
        
        let node = SKShapeNode(circleOfRadius: 16)
        
        switch type{
            case .healthPotion: node.fillColor = .red
            case .specialCharge: node.fillColor = .blue
            case .killAll: node.fillColor = .black
        }
        
        node.position = position
        node.zPosition = 5
        scene.addChild(node)
        
        let moveUp = SKAction.moveBy(x: 0, y: 10, duration: 0.8)
        node.run(.repeatForever(.sequence([moveUp, moveUp.reversed()])))

        entity.add(TransformComponent(node: node))
        
        // Provide an actual CGFloat value for rarity.
        // Example policy: common (health) = 0.2, uncommon (special) = 0.1, rare (killAll) = 0.02
        let rarity: CGFloat
        switch type {
        case .healthPotion:
            rarity = 0.2
        case .specialCharge:
            rarity = 0.1
        case .killAll:
            rarity = 0.02
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
    /// Spawns an indestructible box at `position`.
    /// Boxes use AABB collision resolved by BoxSystem — no SpriteKit physics needed.
    static func makeBox(at position: CGPoint, scene: SKScene) -> Entity {
        let entity = Entity()
        
        let node = SKSpriteNode(imageNamed: AssetName.box)
        node.size      = CGSize(width: 50, height: 50)
        node.position  = position
        node.zPosition = 8
        scene.addChild(node)
        
        entity.add(TransformComponent(node: node))
        entity.add(BoxComponent())
        
        return entity
    }
    
    // MARK: Projectile
    static func makeProjectile(at position: CGPoint, direction: CGVector, scene: SKScene) -> Entity {
        let entity = Entity()
        
        // Visual do tiro (pode substituir por um SKSpriteNode com textura depois)
        let node = SKShapeNode(circleOfRadius: 8)
        node.fillColor = .cyan
        node.strokeColor = .white
        node.lineWidth = 1.5
        node.position = position
        node.zPosition = 9
        scene.addChild(node)
        
        entity.add(TransformComponent(node: node))
        entity.add(ProjectileComponent(damage: 15, direction: direction, speed: 600))
        
        SoundManager.shared.play(SoundManager.shared.attack2, on: node)
        
        return entity
    }
    
    static func makeSpinAttackAction(spriteComponent: SpriteComponent) -> SKAction {
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
    
    
}
