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

        // Clamp to world bounds
        let worldHalf: CGFloat = 1180
        node.position.x = Swift.max(-worldHalf, Swift.min(worldHalf, node.position.x))
        node.position.y = Swift.max(-worldHalf, Swift.min(worldHalf, node.position.y))
        
        // RANGED ATTACK HANDLING (Tiro)
        let isShooting = input.attackDirection.dx != 0 || input.attackDirection.dy != 0
        if isShooting && !sprite.isAttacking && (currentTime - attack.lastAttackTime) >= attack.cooldown {
                    
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

        // ATTACK HANDLING - OTIMIZADO PARA INSTANTÂNEO
        if input.attackPressed && !sprite.isAttacking && (currentTime - attack.lastAttackTime) >= attack.cooldown {
            
            // 1. MARCA O ATAQUE COMO ATIVO IMEDIATAMENTE
            attack.isAttacking = true
            attack.lastAttackTime = currentTime
            
            // 2. ATIVA A ANIMAÇÃO
            sprite.isAttacking = true
            sprite.currentFrame = 0
            sprite.lastFrameTime = currentTime
            
            // 3. JÁ MOSTRA O PRIMEIRO FRAME DO ATAQUE INSTANTANEAMENTE
            if !sprite.attackTextures.isEmpty {
                node.texture = sprite.attackTextures[0]
            }
        }

        // Special handling
        if input.specialPressed && player.specialReady && !sprite.isAttacking {
            player.specialReady = false
            player.killStreak = 0
            
            // MESMA LÓGICA DO ATAQUE NORMAL
            attack.isAttacking = true
            attack.lastAttackTime = currentTime
            sprite.isAttacking = true
            sprite.currentFrame = 0
            sprite.lastFrameTime = currentTime
            
            if !sprite.attackTextures.isEmpty {
                node.texture = sprite.attackTextures[0]
            }
        }
        
        // Update sprite animation with current time
        updateSpriteAnimation(sprite: sprite, node: node, currentTime: currentTime, attack: attack)
    }
    
    private func updateSpriteAnimation(sprite: SpriteComponent, node: SKSpriteNode, currentTime: TimeInterval, attack: AttackComponent) {
        
        // Se não está atacando, faz a animação normal de movimento/idle
        if !sprite.isAttacking {
            if sprite.isMoving {
                // Animação de movimento
                let textures: [SKTexture]
                switch sprite.currentDirection {
                case .down:
                    textures = sprite.downTextures
                case .up:
                    textures = sprite.upTextures
                case .left:
                    textures = sprite.leftTextures
                case .right:
                    textures = sprite.rightTextures
                }
                
                // Controle de tempo para animação de movimento
                if currentTime - sprite.lastFrameTime >= sprite.animationSpeed {
                    sprite.currentFrame = (sprite.currentFrame + 1) % textures.count
                    node.texture = textures[sprite.currentFrame]
                    sprite.lastFrameTime = currentTime
                }
            } else {
                // Idle - volta pro primeiro frame da última direção
                switch sprite.lastDirection {
                case .down:
                    node.texture = sprite.downTextures.first
                case .up:
                    node.texture = sprite.upTextures.first
                case .left:
                    node.texture = sprite.leftTextures.first
                case .right:
                    node.texture = sprite.rightTextures.first
                }
            }
            return
        }
        
        // SE ESTÁ ATACANDO - animação de ataque
        if currentTime - sprite.lastFrameTime >= sprite.animationSpeed {
            
            // Avança para o próximo frame
            sprite.currentFrame += 1
            
            // Verifica se a animação de ataque terminou
            if sprite.currentFrame >= sprite.attackTextures.count {
                // ATAQUE FINALIZADO - reseta tudo
                sprite.isAttacking = false
                attack.isAttacking = false
                sprite.currentFrame = 0
                
                // Volta para o estado apropriado (idle ou movimento)
                if sprite.isMoving {
                    // Se estava andando, volta pra animação de movimento
                    let textures: [SKTexture]
                    switch sprite.currentDirection {
                    case .down:
                        textures = sprite.downTextures
                    case .up:
                        textures = sprite.upTextures
                    case .left:
                        textures = sprite.leftTextures
                    case .right:
                        textures = sprite.rightTextures
                    }
                    node.texture = textures[0]
                } else {
                    // Se estava parado, volta pro idle
                    switch sprite.lastDirection {
                    case .down:
                        node.texture = sprite.downTextures.first
                    case .up:
                        node.texture = sprite.upTextures.first
                    case .left:
                        node.texture = sprite.leftTextures.first
                    case .right:
                        node.texture = sprite.rightTextures.first
                    }
                }
                return
            }
            
            // Atualiza a textura do ataque
            node.texture = sprite.attackTextures[sprite.currentFrame]
            sprite.lastFrameTime = currentTime
        }
    }
}
