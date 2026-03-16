//
//  ProjectileSystem.swift
//  GameChallenge
//
//  Created by Vicenzo Másera on 13/03/26.
//


import SpriteKit

class ProjectileSystem {
    
    
    // Retorna os projéteis que bateram ou expiraram para serem removidos
    func update(projectiles: [Entity], enemies: [Entity], deltaTime: TimeInterval) -> [Entity] {
        var projectilesToRemove = [Entity]()
        
        for proj in projectiles {
            guard let transform = proj.get(TransformComponent.self),
                  let pComp = proj.get(ProjectileComponent.self) else { continue }
            
            // 1. Mover o projétil
            transform.node.position.x += pComp.direction.dx * pComp.speed * deltaTime
            transform.node.position.y += pComp.direction.dy * pComp.speed * deltaTime
            
            // 2. Reduzir tempo de vida
            pComp.lifetime -= deltaTime
            if pComp.lifetime <= 0 {
                projectilesToRemove.append(proj)
                continue
            }
            
            // 3. Checar Colisão com Inimigos
            for enemy in enemies {
                guard let eTransform = enemy.get(TransformComponent.self),
                      let eHealth = enemy.get(HealthComponent.self),
                      eHealth.isAlive else { continue }
                
                // Se a distância entre a bala e o inimigo for menor que o raio de hit (ex: 35)
                let distance = hypot(transform.node.position.x - eTransform.node.position.x, 
                                     transform.node.position.y - eTransform.node.position.y)
                
                if distance <= 35 {
                    // Causa dano e dá feedback visual
                    eHealth.current = Swift.max(0, eHealth.current - pComp.damage)
                    eTransform.node.run(.sequence([
                        .colorize(with: .red, colorBlendFactor: 1, duration: 0.05),
                        .colorize(withColorBlendFactor: 0, duration: 0.1)
                    ]))
                    
                    SoundManager.shared.play(SoundManager.shared.hit2, on: eTransform.node)
                    
                    projectilesToRemove.append(proj)
                    break // A bala some no primeiro inimigo que bater
                }
                
            }
            
        }
        
        return projectilesToRemove
    }
}
