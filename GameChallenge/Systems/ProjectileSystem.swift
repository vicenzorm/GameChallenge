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
}
