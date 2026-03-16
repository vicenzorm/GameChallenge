//
//  EnemySystem.swift
//  GameChallenge
//
//  Created by Bernardo Garcia Fensterseifer on 16/03/26.
//

import SpriteKit
import Foundation

class EnemySystem {

    func update(enemies: [Entity], currentTime: TimeInterval) {
        for enemy in enemies {
            guard
                let spriteComp = enemy.get(EnemySpriteComponent.self),
                let node       = enemy.get(TransformComponent.self)?.node as? SKSpriteNode
            else { continue }

            // Usa a velocidade correta para o estado atual
            guard currentTime - spriteComp.lastFrameTime >= spriteComp.currentAnimationSpeed else { continue }
            spriteComp.lastFrameTime = currentTime

            switch spriteComp.state {
            case .fly:
                spriteComp.currentFrame = (spriteComp.currentFrame + 1) % spriteComp.flyTextures.count
                node.texture = spriteComp.flyTextures[spriteComp.currentFrame]

            case .dmg:
                spriteComp.currentFrame += 1
                if spriteComp.currentFrame >= spriteComp.dmgTextures.count {
                    spriteComp.state = .fly
                    spriteComp.currentFrame = 0
                    node.texture = spriteComp.flyTextures[0]
                } else {
                    node.texture = spriteComp.dmgTextures[spriteComp.currentFrame]
                }

            case .death:
                spriteComp.currentFrame += 1
                if spriteComp.currentFrame >= spriteComp.deathTextures.count {
                    node.run(.sequence([
                        .fadeOut(withDuration: 0.1),
                        .removeFromParent()
                    ]))
                } else {
                    node.texture = spriteComp.deathTextures[spriteComp.currentFrame]
                }
            }
        }
    }

    /// Chame isso quando o inimigo tomar dano (fora do death)
    func triggerDmg(enemy: Entity) {
        guard let sc = enemy.get(EnemySpriteComponent.self),
              sc.state != .death else { return }
        sc.state = .dmg
        sc.currentFrame = 0
    }

    /// Chame isso quando o inimigo morrer
    func triggerDeath(enemy: Entity) {
        guard let sc = enemy.get(EnemySpriteComponent.self),
              !sc.deathStarted else { return }
        sc.deathStarted = true
        sc.state = .death
        sc.currentFrame = 0
    }
}
