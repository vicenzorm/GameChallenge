//
//  CollisionSystem.swift
//  POC-2DGame
//

import SpriteKit
import Foundation

class CollisionSystem {

    // Callback chamado pelo GameScene para acionar o shake + flash
    // Atribuído em GameScene: collisionSystem.onPlayerHit = { [weak self] node in ... }
    var onPlayerHit: ((SKNode) -> Void)?
    var onPlayerHealed: (() -> Void)?
    var onPlayerSpecialCharged: (() -> Void)?
    var onKillAllUsed: (() -> Void)?

    // Cooldown para evitar que shake e flash disparem todo frame durante colisão contínua
    private var hitFeedbackCooldown: TimeInterval = 0
    private let hitFeedbackInterval: TimeInterval = 0.4  // ← segundos entre cada feedback visual

    func checkEnemyPlayerCollisions(
        playerEntity: Entity,
        enemies: [Entity],
        deltaTime: TimeInterval,
        enemySystem: EnemySystem,
        soundManager: SoundManager = .shared
    ) {
        guard
            let playerTransform = playerEntity.get(TransformComponent.self),
            let playerHealth    = playerEntity.get(HealthComponent.self)
        else { return }

        guard !playerHealth.isInvulnerable else { return }

        let pPos = playerTransform.node.position

        // Desconta o cooldown do feedback visual
        hitFeedbackCooldown = max(0, hitFeedbackCooldown - deltaTime)

        var tookDamageThisFrame = false

        for enemy in enemies {
            guard
                let enemyTransform = enemy.get(TransformComponent.self),
                let enemyComp      = enemy.get(EnemyComponent.self)
            else { continue }

            let minDist = 24 + enemyComp.type.radius
            guard pPos.distance(to: enemyTransform.node.position) < minDist else { continue }

            // ── Dano ──────────────────────────────────────────────────────
            playerHealth.current = Swift.max(
                0,
                playerHealth.current - enemyComp.type.damage * CGFloat(deltaTime)
            )
            tookDamageThisFrame = true

            // ── Animação de ataque do inimigo ─────────────────────────────
            enemySystem.triggerSkeletonAtk(enemy: enemy)

            // ── Som (throttle via EnemyComponent) ─────────────────────────
            guard enemyComp.canPlayAttackSound else { continue }
            enemyComp.canPlayAttackSound  = false
            enemyComp.attackSoundCooldown = 0.5

            switch enemyComp.type {
            case .weak:    soundManager.play(soundManager.swordAttack1, on: enemyTransform.node)
            case .normal:  soundManager.play(soundManager.swordAttack2, on: enemyTransform.node)
            case .strong, .shooter, .boss:
                           soundManager.play(soundManager.monsterBite,  on: enemyTransform.node)
            }
        }

        // ── Shake + flash: dispara no máximo 1x a cada hitFeedbackInterval ──
        if tookDamageThisFrame && hitFeedbackCooldown == 0 {
            hitFeedbackCooldown = hitFeedbackInterval
            onPlayerHit?(playerTransform.node)
            vibrate(with: .heavy)
        }
    }

    // MARK: - Coin / Item collection

    func checkCoinCollection(playerEntity: Entity, coins: [Entity]) -> [Entity] {
        guard let playerTransform = playerEntity.get(TransformComponent.self) else { return [] }
        let pPos = playerTransform.node.position
        return coins.filter {
            guard let t = $0.get(TransformComponent.self) else { return false }
            return pPos.distance(to: t.node.position) < 32
        }
    }

    func handleItemPickup(player: Entity, item: Entity, scene: GameScene) {
        guard let itemType = item.get(ItemComponent.self)?.type else { return }
        guard let playerNode = player.get(TransformComponent.self)?.node else {return}

        switch itemType {
        case .healthPotion:
            SoundManager.shared.play(SoundManager.shared.healthPickup, on: playerNode)
            if let hp = player.get(HealthComponent.self) {
                hp.current = min(hp.max, hp.current + 50)
                onPlayerHealed?()
            }
        case .specialCharge:
            SoundManager.shared.play(SoundManager.shared.specialPickup, on: playerNode)
            if let pl = player.get(PlayerComponent.self) {
                pl.killStreak   = max(pl.killStreak, PlayerComponent.weakKillsNeeded)
                pl.specialReady = true
                onPlayerSpecialCharged?()   // ← adicione aqui
            }
        case .killAll:
            SoundManager.shared.play(SoundManager.shared.killAll, on: playerNode)
            scene.clearEnemiesAroundPlayer()
            onKillAllUsed?()   
        }

        item.get(TransformComponent.self)?.node.removeFromParent()
    }
}
