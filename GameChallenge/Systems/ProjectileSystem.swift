//
//  ProjectileSystem.swift
//  GameChallenge
//
//  Created by Vicenzo Másera on 13/03/26.
//


import SpriteKit

class ProjectileSystem {
    
    
    // Retorna os projéteis que bateram ou expiraram para serem removidos
    func update(
        projectiles: [Entity],
        enemies: [Entity],
        deltaTime: TimeInterval,
        enemySystem: EnemySystem        // ← novo parâmetro
    ) -> [Entity] {
        var projectilesToRemove = [Entity]()

        for proj in projectiles {
            guard let transform = proj.get(TransformComponent.self),
                  let pComp = proj.get(ProjectileComponent.self) else { continue }

            transform.node.position.x += pComp.direction.dx * pComp.speed * deltaTime
            transform.node.position.y += pComp.direction.dy * pComp.speed * deltaTime

            pComp.lifetime -= deltaTime
            if pComp.lifetime <= 0 {
                projectilesToRemove.append(proj)
                continue
            }

            for enemy in enemies {
                guard let eTransform = enemy.get(TransformComponent.self),
                      let eHealth = enemy.get(HealthComponent.self),
                      eHealth.isAlive else { continue }

                let distance = hypot(
                    transform.node.position.x - eTransform.node.position.x,
                    transform.node.position.y - eTransform.node.position.y
                )

                if distance <= 35 {
                    eHealth.current = Swift.max(0, eHealth.current - pComp.damage)
                    enemySystem.triggerDmg(enemy: enemy)   // ← substitui o colorize

                    SoundManager.shared.play(SoundManager.shared.hit2, on: eTransform.node)

                    projectilesToRemove.append(proj)
                    break
                }
            }
        }

        return projectilesToRemove
    }
    
    func updateEnemyProjectiles(
        projectiles: [Entity],
        playerEntity: Entity,
        deltaTime: TimeInterval,
        onPlayerHit: ((SKNode) -> Void)? = nil   // ← adicione esse parâmetro
    ) -> [Entity] {
        var toRemove = [Entity]()

        guard
            let playerTransform = playerEntity.get(TransformComponent.self),
            let playerHealth    = playerEntity.get(HealthComponent.self)
        else { return toRemove }

        for proj in projectiles {
            guard
                let transform = proj.get(TransformComponent.self),
                let pComp     = proj.get(ProjectileComponent.self)
            else { continue }

            transform.node.position.x += pComp.direction.dx * pComp.speed * deltaTime
            transform.node.position.y += pComp.direction.dy * pComp.speed * deltaTime

            pComp.lifetime -= deltaTime
            if pComp.lifetime <= 0 {
                toRemove.append(proj)
                continue
            }

            let dist = hypot(
                transform.node.position.x - playerTransform.node.position.x,
                transform.node.position.y - playerTransform.node.position.y
            )
            if dist <= 28 {
                guard !playerHealth.isInvulnerable else {
                    toRemove.append(proj)
                    continue
                }
                playerHealth.current = Swift.max(0, playerHealth.current - pComp.damage)
                onPlayerHit?(playerTransform.node)   // ← dispara o feedback
                toRemove.append(proj)
            }
        }

        return toRemove
    }
}
