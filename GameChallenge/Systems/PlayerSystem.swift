//
//  PlayerSystem.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 12/03/26.
//

import SpriteKit
import CoreMotion
import Foundation

class PlayerSystem {
    
    private var lastFootstepTime: TimeInterval = 0
    private let footstepInterval: TimeInterval = 0.25
    
    func update(
        playerEntity: Entity,
        motionDirection: CGVector,
        deltaTime: TimeInterval,
        currentTime: TimeInterval
    ) {
        guard
            let input    = playerEntity.get(InputComponent.self),
            let movement = playerEntity.get(MovementComponent.self),
            let attack   = playerEntity.get(AttackComponent.self),
            let player   = playerEntity.get(PlayerComponent.self),
            let sprite   = playerEntity.get(SpriteComponent.self),
            let node     = playerEntity.get(TransformComponent.self)?.node as? SKSpriteNode
        else { return }

        // Apply motion-based direction
        movement.velocity = CGVector(
            dx: motionDirection.dx * movement.speed,
            dy: motionDirection.dy * movement.speed
        )

        // Determine if player is moving
        let isMoving = motionDirection.dx != 0 || motionDirection.dy != 0
        sprite.isMoving = isMoving

        // Update direction based on movement (mas não durante o ataque)
        if !sprite.isAttacking {
            if isMoving {
                // Determine primary direction based on motion vector
                if abs(motionDirection.dx) > abs(motionDirection.dy) {
                    // Horizontal movement is dominant
                    sprite.currentDirection = motionDirection.dx > 0 ? .right : .left
                } else {
                    // Vertical movement is dominant
                    sprite.currentDirection = motionDirection.dy > 0 ? .up : .down
                }
                
                // Save last direction when moving
                sprite.lastDirection = sprite.currentDirection
            }
        }

        // Clamp to world bounds — deve ser metade do worldSize menos margem do sprite
        let worldHalf: CGFloat = 880   // 1800/2 - margem de ~20px
        node.position.x = Swift.max(-worldHalf, Swift.min(worldHalf, node.position.x))
        node.position.y = Swift.max(-worldHalf, Swift.min(worldHalf, node.position.y))
        
        // RANGED ATTACK HANDLING (Tiro)
        let isShooting = input.attackDirection.dx != 0 || input.attackDirection.dy != 0
        if isShooting && !sprite.isAttacking && (currentTime - attack.lastAttackTime) >= attack.cooldown {
                    
            vibrate(with: .light)
            attack.lastAttackTime = currentTime
            attack.wantsToShoot = true
            attack.shootDirection = input.attackDirection
                    
            // Opcional: Vira o personagem para o lado do tiro
            if abs(input.attackDirection.dx) > abs(input.attackDirection.dy) {
                sprite.currentDirection = input.attackDirection.dx > 0 ? .right : .left
            } else {
                sprite.currentDirection = input.attackDirection.dy > 0 ? .up : .down
            }
        }

        // "ATTACK HANDLING"
        if input.attackPressed && !sprite.isAttacking && (currentTime - attack.lastAttackTime) >= attack.cooldown {
            vibrate(with: .medium)
            attack.isAttacking    = true
            attack.lastAttackTime = currentTime
            attack.didApplyDamage = false
            sprite.isAttacking    = true
            sprite.isSpecialAttack = false
            sprite.currentFrame   = 0
            sprite.lastFrameTime  = currentTime
            node.setScale(1.5)
            node.texture = sprite.currentAttackTextures.first
            
            SoundManager.shared.play(SoundManager.shared.attack1, on: node)
        }

        // "Special handling"
        if input.specialPressed && player.specialReady && !sprite.isAttacking {
            vibrate(with: .heavy)
            player.specialReady   = false
            player.killStreak     = 0
            attack.isAttacking    = true
            attack.lastAttackTime = currentTime
            attack.didApplyDamage = false
            sprite.isAttacking    = true
            sprite.isSpecialAttack = true
            sprite.currentFrame   = 0
            sprite.lastFrameTime  = currentTime
            node.setScale(1.5)
            node.texture = sprite.attackTextures.first
        }
        
        // Update sprite animation with current time
        guard !sprite.isFlashing else { return }
        updateSpriteAnimation(sprite: sprite, node: node, currentTime: currentTime, attack: attack)

    }
    
    private func updateSpriteAnimation(
        sprite: SpriteComponent,
        node: SKSpriteNode,
        currentTime: TimeInterval,
        attack: AttackComponent
    ) {
        guard currentTime - sprite.lastFrameTime >= sprite.animationSpeed else { return }
        sprite.lastFrameTime = currentTime

        // ── IDLE ──────────────────────────────────────────────────────────────
        if !sprite.isAttacking && !sprite.isMoving {
            node.texture = sprite.currentIdleTexture
            return
        }

        // ── MOVIMENTO ─────────────────────────────────────────────────────────
        
        if !sprite.isAttacking {
            let textures: [SKTexture]
            switch sprite.currentDirection {
            case .down:  textures = sprite.downTextures
            case .up:    textures = sprite.upTextures
            case .left:  textures = sprite.leftTextures
            case .right: textures = sprite.rightTextures
            }
            sprite.currentFrame = (sprite.currentFrame + 1) % textures.count
            node.texture = textures[sprite.currentFrame]
            
            if sprite.isMoving && currentTime - lastFootstepTime > footstepInterval {
                SoundManager.shared.play(SoundManager.shared.footstep, on: node)
                lastFootstepTime = currentTime
            }
            
            return
        }

        // ── ATAQUE ────────────────────────────────────────────────────────────
        let atkFrames = sprite.isSpecialAttack
            ? sprite.attackTextures
            : sprite.currentAttackTextures

        sprite.currentFrame += 1

        if sprite.currentFrame >= atkFrames.count {
            sprite.isAttacking     = false
            sprite.isSpecialAttack = false
            attack.isAttacking     = false
            sprite.currentFrame    = 0
            node.setScale(1.0)  // ← adiciona aqui
            node.texture = sprite.isMoving
                ? sprite.currentAttackTextures.first
                : sprite.currentIdleTexture
            return
        }

        node.texture = atkFrames[sprite.currentFrame]
    }
}
