//
//  WaveSystem.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 12/03/26.
//

import SpriteKit
import CoreMotion
import Foundation

class WaveSystem {
    private(set) var currentWave: Int = 0
    private(set) var isSpawning: Bool = false
    
    private var spawnTimer:        TimeInterval = 0
    private var currentSpawnQueue: [EnemyComponent.EnemyType] = []
    private var waveCleared:       Bool = false
    
    var onSpawnEnemy:    ((EnemyComponent.EnemyType, CGPoint) -> Void)?
    var onWaveStart:     ((Int) -> Void)?
    var onWaveEnd:       ((Int) -> Void)?   // fires when wave is cleared — use to show cutscene
    
    struct WaveConfig {
        let weak: Int; let normal: Int; let strong: Int; let shooter: Int
        let spawnInterval: TimeInterval
        
        static func config(forWave wave: Int) -> WaveConfig {
            let w = Swift.min(wave, 20)
            return WaveConfig(
                weak:          2 + w * 3,
                normal:        w > 2 ? (w - 2) * 2 : 0,
                strong:        w > 5 ? (w - 5)     : 0,
                shooter:       w > 2 ? Swift.min((w - 2), 3) : 0,
                spawnInterval: Swift.max(0.3, 1.5 - Double(w) * 0.06)
            )
        }
    }
    
    func startNextWave(sceneSize: CGSize) {
        currentWave += 1
        waveCleared  = false
        let config   = WaveConfig.config(forWave: currentWave)
        
        var queue: [EnemyComponent.EnemyType] = []
        queue += Array(repeating: .weak,    count: config.weak)
        queue += Array(repeating: .normal,  count: config.normal)
        queue += Array(repeating: .strong,  count: config.strong)
        queue += Array(repeating: .shooter, count: config.shooter)
        queue.shuffle()
        queue.append(.boss)
        
        currentSpawnQueue  = queue
        spawnTimer         = 0
        isSpawning         = true
        
        onWaveStart?(currentWave)
    }
    
    func update(
        deltaTime: TimeInterval,
        activeEnemies: Int,
        sceneSize: CGSize,
        playerPosition: CGPoint
    ) {
        // Spawning
        if isSpawning {
            spawnTimer -= deltaTime
            if spawnTimer <= 0 && !currentSpawnQueue.isEmpty {
                let type = currentSpawnQueue.removeFirst()
                onSpawnEnemy?(type, spawnPosition(avoiding: playerPosition, sceneSize: sceneSize))
                spawnTimer = WaveConfig.config(forWave: currentWave).spawnInterval
                if currentSpawnQueue.isEmpty { isSpawning = false }
            }
        }
        
        // Todos spawnou + todos morreram → notifica UMA vez
        if !isSpawning && activeEnemies == 0 && !waveCleared {
            waveCleared = true
            onWaveEnd?(currentWave)
        }
    }
    
    private func spawnPosition(avoiding playerPos: CGPoint, sceneSize: CGSize) -> CGPoint {
        let hw = sceneSize.width  / 2 - 80
        let hh = sceneSize.height / 2 - 80
        var pos: CGPoint
        repeat {
            pos = CGPoint(x: CGFloat.random(in: -hw...hw),
                          y: CGFloat.random(in: -hh...hh))
        } while pos.distance(to: playerPos) < 200
        return pos
    }
}
