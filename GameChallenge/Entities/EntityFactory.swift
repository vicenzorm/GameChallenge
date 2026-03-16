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
    // Player animation frames
    static let playerDown = "player_down_"      // followed by 1,2,3,4
    static let playerUp = "player_up_"          // followed by 1,2,3,4
    static let playerLeft = "player_left_"      // followed by 1,2,3,4
    static let playerRight = "player_right_"    // followed by 1,2,3,4
    static let playerAttack = "player_attack_"  // followed by 1,2,3,4,5,6
    
    // Static sprites
    static let enemyWeak   = "enemy_weak"       // ← small enemy image
    static let enemyNormal = "enemy_normal"     // ← medium enemy image
    static let enemyStrong = "enemy_strong"     // ← large enemy image
    static let coin        = "coin_sprite"      // ← coin image
    static let box         = "box_sprite"
}

class EntityFactory {

    // MARK: Player
    static func makePlayer(at position: CGPoint, scene: SKScene) -> Entity {
        let entity = Entity()

        // Load textures for different directions
        let downTextures = loadTextures(baseName: AssetName.playerDown, count: 4)
        let upTextures = loadTextures(baseName: AssetName.playerUp, count: 4)
        let leftTextures = loadTextures(baseName: AssetName.playerLeft, count: 4)
        let rightTextures = loadTextures(baseName: AssetName.playerRight, count: 4)
        let attackTextures = loadTextures(baseName: AssetName.playerAttack, count: 4)
        
        // Create sprite node with initial texture (down)
        let node = SKSpriteNode(texture: downTextures.first)
        node.size = CGSize(width: 68, height: 68)   // fixed size — adjust if needed
        node.position = position
        node.zPosition = 10
        scene.addChild(node)

        // Add components
        entity.add(TransformComponent(node: node))
        entity.add(HealthComponent(max: 100))
        entity.add(MovementComponent(speed: 220))
        entity.add(PlayerComponent())
        entity.add(InputComponent())
        entity.add(AttackComponent(damage: 4, range: 70, cooldown: 0.4))
        
        // Add sprite component with all animations
        let spriteComponent = SpriteComponent(
            downTextures: downTextures,
            upTextures: upTextures,
            leftTextures: leftTextures,
            rightTextures: rightTextures,
            attackTextures: attackTextures
        )
        entity.add(spriteComponent)

        return entity
    }

    // MARK: Enemy
    static func makeEnemy(type: EnemyComponent.EnemyType, at position: CGPoint, scene: SKScene) -> Entity {
        let entity = Entity()

        let imageName: String
        let spriteSize: CGSize
        switch type {
        case .weak:
            imageName  = AssetName.enemyWeak
            spriteSize = CGSize(width: 68, height: 68)   // fixed size for weak enemy
        case .normal:
            imageName  = AssetName.enemyNormal
            spriteSize = CGSize(width: 88, height: 88)   // fixed size for normal enemy
        case .strong:
            imageName  = AssetName.enemyStrong
            spriteSize = CGSize(width: 128, height: 128)   // fixed size for strong enemy
        }

        let node = SKSpriteNode(imageNamed: imageName)
        node.size      = spriteSize
        node.position  = position
        node.zPosition = 8
        scene.addChild(node)

        // Health bar background
        let barWidth: CGFloat  = spriteSize.width * 1.2
        let barHeight: CGFloat = 5
        let barBg = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 2)
        barBg.fillColor   = UIColor(white: 0.2, alpha: 0.85)
        barBg.strokeColor = .clear
        barBg.position    = CGPoint(x: 0, y: spriteSize.height / 2 + 8)
        barBg.zPosition   = 1
        node.addChild(barBg)

        // Health bar fill
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
    
    // MARK: - Helper Methods
    
    /// Loads a sequence of textures with a base name and count
    /// Example: loadTextures(baseName: "player_down_", count: 4) loads player_down_1, player_down_2, etc.
    private static func loadTextures(baseName: String, count: Int) -> [SKTexture] {
        var textures: [SKTexture] = []
        
        for i in 1...count {
            let textureName = "\(baseName)\(i)"
            
            // Try to load the texture
            if let texture = UIImage(named: textureName) {
                textures.append(SKTexture(image: texture))
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
        node.zPosition = 6
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
        
        return entity
    }
}
