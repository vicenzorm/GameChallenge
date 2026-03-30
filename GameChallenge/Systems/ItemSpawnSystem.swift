//
//  ItemSpawnSystem.swift
//  GameChallenge
//
//  Created by Leonel Ferraz Hernandez on 17/03/26.
//

import Foundation
import CoreGraphics

class ItemSpawnSystem {
    private var lastSpawnTime: TimeInterval = 0
    private let spawnInterval: TimeInterval = 10.0 // Tenta spawnar a cada 10 segundos
    
    func update(deltaTime: TimeInterval, currentTime: TimeInterval, activeItems: Int, sceneSize: CGSize, scene: GameScene) {
        // Se já tem muitos itens no mapa, não cria mais
        guard activeItems < 3 else { return }
        
        if currentTime - lastSpawnTime > spawnInterval {
            lastSpawnTime = currentTime
            
            // Lógica de sorte (30% de chance de realmente aparecer um item)
            if CGFloat.random(in: 0...1) < 0.3 {
                spawnRandomItem(sceneSize: sceneSize, scene: scene)
            }
        }
    }
    
    private func spawnRandomItem(sceneSize: CGSize, scene: GameScene) {
        let rand = CGFloat.random(in: 0...1)
        let type: ItemComponent.ItemType
        
        // Baseado na raridade que você quer
        if rand < 0.05 { type = .killAll }        // 10% chance
        else if rand < 0.25 { type = .specialCharge } // 20% chance
        else if rand < 0.50 { type = .healthPotion } // 50% chance
        else { type = .shuriken }
        
        let x = CGFloat.random(in: -sceneSize.width/2 + 200 ... sceneSize.width/2 - 200)
        let y = CGFloat.random(in: -sceneSize.height/2 + 200 ... sceneSize.height/2 - 200)
        
        let newItem = EntityFactory.makeConsumable(type: type, at: CGPoint(x: x, y: y), scene: scene)
        scene.addItemEntity(newItem) // Você vai precisar criar esse método na GameScene
    }
}
