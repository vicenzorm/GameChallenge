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
    private var betweenWaveTimer:  TimeInterval = 0
    private var waitingForNextWave: Bool = false

    var onSpawnEnemy:    ((EnemyComponent.EnemyType, CGPoint) -> Void)?
    var onWaveStart:     ((Int) -> Void)?
    var onWaveEnd:       ((Int) -> Void)?   // fires when wave is cleared — use to show cutscene
    var onWaveCountdown: ((Int) -> Void)?   // fires each second during break

    struct WaveConfig {
        let weak: Int; let normal: Int; let strong: Int
        let spawnInterval: TimeInterval
        static let betweenWaveDelay: TimeInterval = 5.0

        static func config(forWave wave: Int) -> WaveConfig {
            let w = Swift.min(wave, 20)
            return WaveConfig(
                weak:          2 + w * 3,
                normal:        w > 2 ? (w - 2) * 2 : 0,
                strong:        w > 5 ? (w - 5) : 0,
                spawnInterval: Swift.max(0.3, 1.5 - Double(w) * 0.06)
            )
        }
    }

    func startNextWave(sceneSize: CGSize) {
        currentWave += 1
        let config = WaveConfig.config(forWave: currentWave)

        var queue: [EnemyComponent.EnemyType] = []
        queue += Array(repeating: .weak,   count: config.weak)
        queue += Array(repeating: .normal, count: config.normal)
        queue += Array(repeating: .strong, count: config.strong)
        queue.shuffle()

        currentSpawnQueue   = queue
        spawnTimer          = 0
        isSpawning          = true
        waitingForNextWave  = false

        onWaveStart?(currentWave)
    }

    func update(
        deltaTime: TimeInterval,
        activeEnemies: Int,
        sceneSize: CGSize,
        playerPosition: CGPoint
    ) {
        // ── Between waves countdown ──────────────────────────────
        if waitingForNextWave {
            let previousSeconds = Int(ceil(betweenWaveTimer))
            betweenWaveTimer -= deltaTime
            let currentSeconds  = Int(ceil(betweenWaveTimer))
            if currentSeconds != previousSeconds {
                onWaveCountdown?(Swift.max(0, currentSeconds))
            }
            if betweenWaveTimer <= 0 {
                startNextWave(sceneSize: sceneSize)
            }
            return
        }

        // ── Spawning ─────────────────────────────────────────────
        if isSpawning {
            spawnTimer -= deltaTime
            if spawnTimer <= 0 && !currentSpawnQueue.isEmpty {
                let type = currentSpawnQueue.removeFirst()
                onSpawnEnemy?(type, spawnPosition(avoiding: playerPosition, sceneSize: sceneSize))
                spawnTimer = WaveConfig.config(forWave: currentWave).spawnInterval
                if currentSpawnQueue.isEmpty { isSpawning = false }
            }
        }

        // ── All spawned + all dead → notify for cutscene, then break ──
        if !isSpawning && activeEnemies == 0 && !waitingForNextWave {
            waitingForNextWave = true
            betweenWaveTimer   = WaveConfig.betweenWaveDelay
            onWaveEnd?(currentWave)   // GameScene uses this to show the cutscene
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
