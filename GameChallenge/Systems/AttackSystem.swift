//
//  AttackSystem.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 12/03/26.
//

import SpriteKit
import CoreMotion
import Foundation

class AttackSystem {
   
    
    func update(
        attackerEntity: Entity,
        enemies: [Entity],
        scene: SKScene,
        isSpecial: Bool = false
    ) {
        
        guard
            let attackComp      = attackerEntity.get(AttackComponent.self),
            attackComp.isAttacking,
            let attackerTransform = attackerEntity.get(TransformComponent.self),
            !attackComp.didApplyDamage
        else { return }

        let origin = attackerTransform.node.position
        let range  = isSpecial ? attackComp.range * 2.5 : attackComp.range
        let damage = isSpecial ? attackComp.damage * 3  : attackComp.damage

        // Sword arc visual
        
        attackComp.attackNode?.removeFromParent()
        let arc = SKShapeNode(circleOfRadius: range)
        arc.fillColor   = isSpecial
            ? UIColor.cyan.withAlphaComponent(0.25)
            : UIColor.white.withAlphaComponent(0.15)
        arc.strokeColor = isSpecial ? .cyan : .white
        arc.lineWidth   = 1.5
        arc.position    = origin
        arc.zPosition   = 5
        scene.addChild(arc)
        attackComp.attackNode = arc
        arc.run(.sequence([.fadeOut(withDuration: 0.2), .removeFromParent()]))

        // Hit enemies in range
        
        var didHitEnemy = false
        
        for enemy in enemies {
            guard
                let enemyTransform = enemy.get(TransformComponent.self),
                let health         = enemy.get(HealthComponent.self)
            else { continue }

            if origin.distance(to: enemyTransform.node.position) <= range {
                health.current = Swift.max(0, health.current - damage)
                enemyTransform.node.run(.sequence([
                    .colorize(with: .red, colorBlendFactor: 1, duration: 0.05),
                    .colorize(withColorBlendFactor: 0, duration: 0.1)
                ]))
                didHitEnemy = true
                
            }
        }
        if didHitEnemy {
            SoundManager.shared.play(SoundManager.shared.hit1, on: attackerTransform.node)
        }
        
        attackComp.didApplyDamage = true
    }
}
