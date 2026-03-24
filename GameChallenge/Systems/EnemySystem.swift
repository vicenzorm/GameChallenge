//
//  EnemySystem.swift
//  GameChallenge
//
//  Created by Bernardo Garcia Fensterseifer on 16/03/26.
//

import SpriteKit
import Foundation

class EnemySystem {

    // MARK: - Update principal

    func update(enemies: [Entity], currentTime: TimeInterval) {
        for enemy in enemies {
            guard let node = enemy.get(TransformComponent.self)?.node as? SKSpriteNode else { continue }

            if let sc = enemy.get(SkeletonSpriteComponent.self) {
                updateSkeleton(sc: sc, node: node, currentTime: currentTime)
            } else if let ec = enemy.get(EnemySpriteComponent.self) {
                updateBix(sc: ec, node: node, currentTime: currentTime)
            }
        }
    }

    // MARK: - Skeleton

    private func updateSkeleton(sc: SkeletonSpriteComponent, node: SKSpriteNode, currentTime: TimeInterval) {
        guard currentTime - sc.lastFrameTime >= sc.currentSpeed else { return }
        sc.lastFrameTime = currentTime

        switch sc.state {

        case .walk:
            sc.currentFrame = (sc.currentFrame + 1) % sc.walkTextures.count
            node.texture = sc.walkTextures[sc.currentFrame]

        case .atk:
            sc.currentFrame += 1
            if sc.currentFrame >= sc.atkTextures.count {
                // Volta para walk ao terminar
                sc.state = .walk
                sc.isPlayingOneShot = false
                sc.currentFrame = 0
                node.texture = sc.walkTextures[0]
            } else {
                node.texture = sc.atkTextures[sc.currentFrame]
            }

        case .dmg:
            sc.currentFrame += 1
            if sc.currentFrame >= sc.dmgTextures.count {
                sc.state = .walk
                sc.isPlayingOneShot = false
                sc.currentFrame = 0
                node.texture = sc.walkTextures[0]
            } else {
                node.texture = sc.dmgTextures[sc.currentFrame]
            }

        case .die:
            sc.currentFrame += 1
            if sc.currentFrame >= sc.dieTextures.count {
                node.run(.sequence([
                    .fadeOut(withDuration: 0.1),
                    .removeFromParent()
                ]))
            } else {
                node.texture = sc.dieTextures[sc.currentFrame]
            }
        }
    }

    // MARK: - Bix (sistema original)

    private func updateBix(sc: EnemySpriteComponent, node: SKSpriteNode, currentTime: TimeInterval) {
        guard currentTime - sc.lastFrameTime >= sc.currentAnimationSpeed else { return }
        sc.lastFrameTime = currentTime

        switch sc.state {
        case .fly:
            sc.currentFrame = (sc.currentFrame + 1) % sc.flyTextures.count
            node.texture = sc.flyTextures[sc.currentFrame]

        case .dmg:
            sc.currentFrame += 1
            if sc.currentFrame >= sc.dmgTextures.count {
                sc.state = .fly
                sc.currentFrame = 0
                node.texture = sc.flyTextures[0]
            } else {
                node.texture = sc.dmgTextures[sc.currentFrame]
            }

        case .death:
            sc.currentFrame += 1
            if sc.currentFrame >= sc.deathTextures.count {
                node.run(.sequence([
                    .fadeOut(withDuration: 0.1),
                    .removeFromParent()
                ]))
            } else {
                node.texture = sc.deathTextures[sc.currentFrame]
            }
        }
    }

    // MARK: - Triggers públicos (funcionam para ambos os sistemas)

    /// Chame quando o inimigo tomar dano
    func triggerDmg(enemy: Entity) {
        if let sc = enemy.get(SkeletonSpriteComponent.self) {
            guard sc.state != .die, !sc.isPlayingOneShot else { return }
            sc.state = .dmg
            sc.isPlayingOneShot = true
            sc.currentFrame = 0
        } else if let ec = enemy.get(EnemySpriteComponent.self) {
            guard ec.state != .death else { return }
            ec.state = .dmg
            ec.currentFrame = 0
        }
    }

    /// Chame quando o inimigo morrer
    func triggerDeath(enemy: Entity) {
        if let sc = enemy.get(SkeletonSpriteComponent.self) {
            guard !sc.deathStarted else { return }
            sc.deathStarted = true
            sc.isPlayingOneShot = true
            sc.state = .die
            sc.currentFrame = 0
        } else if let ec = enemy.get(EnemySpriteComponent.self) {
            guard !ec.deathStarted else { return }
            ec.deathStarted = true
            ec.state = .death
            ec.currentFrame = 0
        }
    }

    /// Chame quando o skeleton colidir com o player
    func triggerSkeletonAtk(enemy: Entity) {
        guard let sc = enemy.get(SkeletonSpriteComponent.self),
              sc.state != .die,
              !sc.isPlayingOneShot
        else { return }
        sc.state = .atk
        sc.isPlayingOneShot = true
        sc.currentFrame = 0
    }
}
