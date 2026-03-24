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
    private(set) var totalEnemiesInWave: Int = 0
    private(set) var enemiesKilled:      Int = 0

    private var spawnTimer:        TimeInterval = 0
    private var currentSpawnQueue: [EnemyComponent.EnemyType] = []
    private var waveCleared:       Bool = false

    var onSpawnEnemy:    ((EnemyComponent.EnemyType, CGPoint) -> Void)?
    var onWaveStart:     ((Int) -> Void)?
    var onWaveEnd:       ((Int) -> Void)?

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - WaveConfig  ← PRINCIPAL PONTO DE AJUSTE DE DIFICULDADE
    // ═══════════════════════════════════════════════════════════════════
    //
    // Cada wave tem uma WaveConfig calculada em `config(forWave:)`.
    // Altere as fórmulas abaixo para controlar:
    //
    //  • weak          → inimigos fracos por wave
    //  • normal        → inimigos normais (aparecem a partir da wave 3)
    //  • strong        → inimigos fortes  (aparecem a partir da wave 6)
    //  • shooter       → inimigos atirador (aparecem a partir da wave 3, máx 3)
    //  • spawnInterval → segundos entre cada spawn (diminui com as waves)
    //
    // EXEMPLO de curva mais suave:
    //   weak:   1 + w * 2          (começa com 3, +2 por wave)
    //   normal: w > 3 ? (w-3)      (aparece mais tarde, sobe mais devagar)
    //   strong: w > 8 ? (w-8)      (aparece ainda mais tarde)
    //   spawnInterval: max(0.5, 2.0 - Double(w) * 0.07)   (mais lento no início)

    struct WaveConfig {
        let weak: Int
        let normal: Int
        let strong: Int
        let shooter: Int
        let spawnInterval: TimeInterval

        static func config(forWave wave: Int) -> WaveConfig {
            // ─────────────────────────────────────────────────────────
            // Teto de dificuldade: a partir da wave 20 não escala mais.
            // Aumente esse valor para prolongar a progressão.
            // ─────────────────────────────────────────────────────────
            let w = Swift.min(wave, 20)  // ← teto de escala (wave máxima balanceada)

            return WaveConfig(
                // ── Quantidade de cada tipo ───────────────────────────
                // Fórmula: base + (w * multiplicador)
                // Aumente o multiplicador para progressão mais agressiva.
                weak:    2 + w * 3,                              // wave 1 = 5,  wave 10 = 32
                normal:  w > 2 ? (w - 2) * 2 : 0,               // aparece na wave 3; wave 10 = 16
                strong:  w > 5 ? (w - 5)     : 0,               // aparece na wave 6; wave 10 = 5
                shooter: w > 2 ? Swift.min((w - 2), 3) : 0,     // aparece na wave 3; máx 3 por wave ← aumente o máx se quiser mais

                // ── Velocidade de spawn ───────────────────────────────
                // Diminui com o tempo. Mínimo de 0.3 s entre spawns.
                // Aumente o 0.3 para nunca deixar muito frenético.
                // Aumente o 1.5 para começar mais lento.
                // Aumente o 0.06 para a aceleração ser mais rápida.
                spawnInterval: Swift.max(0.3, 1.5 - Double(w) * 0.06)
                //                       ↑ mínimo   ↑ início  ↑ aceleração por wave
            )
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Escala de stats por wave  ← VIDA E FORÇA DOS INIMIGOS
    // ═══════════════════════════════════════════════════════════════════
    //
    // Use esse método nos seus EntityFactory / EnemyComponent ao criar
    // inimigos. Passe `waveSystem.currentWave` e o tipo do inimigo, e
    // aplique os multiplicadores retornados ao HP e ao dano base.
    //
    // ONDE USAR:
    //   Em EntityFactory.makeEnemy(type:at:scene:), adicione algo como:
    //
    //     let scale  = WaveSystem.enemyScale(wave: currentWave, type: type)
    //     let health = HealthComponent(max: Int(Float(type.baseHP) * scale.hp))
    //     // e passe scale.damage para o componente de dano do inimigo
    //
    // AJUSTE:
    //   • hpGrowth     → quanto % de HP a mais por wave  (0.10 = +10% por wave)
    //   • dmgGrowth    → quanto % de dano a mais por wave
    //   • strongFactor → inimigos fortes crescem mais rápido que os fracos

    struct EnemyScaleFactors {
        let hp:     Float   // multiplique pelo HP base do inimigo
        let damage: Float   // multiplique pelo dano base do inimigo
    }

    static func enemyScale(wave: Int, type: EnemyComponent.EnemyType) -> EnemyScaleFactors {
        let w = Float(Swift.min(wave, 20))   // mesmo teto do WaveConfig

        // ── Crescimento base (vale para todos os tipos) ───────────────
        let hpGrowth  = w * 0.10   // +10% de HP por wave  ← ajuste aqui
        let dmgGrowth = w * 0.07   // +7%  de dano por wave ← ajuste aqui

        // ── Multiplicador extra por tipo ──────────────────────────────
        // Inimigos mais fortes escalam mais rápido para manter a sensação
        // de ameaça crescente mesmo no late-game.
        let typeMultiplier: Float
        switch type {
        case .weak:    typeMultiplier = 1.0   // escala padrão
        case .normal:  typeMultiplier = 1.1   // +10% a mais que weak
        case .strong:  typeMultiplier = 1.25  // +25% a mais que weak
        case .shooter: typeMultiplier = 1.0   // igual ao weak (ameaça = alcance, não bulk)
        case .boss:    typeMultiplier = 1.5   // boss escala bem mais rápido ← aumente para boss mais brutal
        }

        return EnemyScaleFactors(
            hp:     (1 + hpGrowth)  * typeMultiplier,
            damage: (1 + dmgGrowth) * typeMultiplier
        )
    }

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - startNextWave
    // ═══════════════════════════════════════════════════════════════════

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

        currentSpawnQueue    = queue
        totalEnemiesInWave   = queue.count   // ← total real da wave, sempre atualizado
        enemiesKilled        = 0             // ← reseta o contador
        spawnTimer           = 0
        isSpawning           = true

        onWaveStart?(currentWave)
    }
    
    // ═══════════════════════════════════════════════════════════════════
    // MARK: - update
    // ═══════════════════════════════════════════════════════════════════

    func update(
        deltaTime: TimeInterval,
        activeEnemies: Int,
        sceneSize: CGSize,
        playerPosition: CGPoint
    ) {
        // Vai consumindo a fila de spawn a cada `spawnInterval` segundos
        if isSpawning {
            spawnTimer -= deltaTime
            if spawnTimer <= 0 && !currentSpawnQueue.isEmpty {
                let type = currentSpawnQueue.removeFirst()
                onSpawnEnemy?(type, spawnPosition(avoiding: playerPosition, sceneSize: sceneSize))
                spawnTimer = WaveConfig.config(forWave: currentWave).spawnInterval
                if currentSpawnQueue.isEmpty { isSpawning = false }
            }
        }

        // Wave encerrada: todos foram spawnados E todos morreram
        if !isSpawning && activeEnemies == 0 && !waveCleared {
            waveCleared = true
            onWaveEnd?(currentWave)
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    // MARK: - spawnPosition
    // ═══════════════════════════════════════════════════════════════════
    //
    // Inimigos spawnam a pelo menos 200 pt do jogador para evitar spawn
    // dentro do campo de visão imediato. Aumente esse valor para dar
    // mais tempo de reação ao jogador.

    private func spawnPosition(avoiding playerPos: CGPoint, sceneSize: CGSize) -> CGPoint {
        let hw = sceneSize.width  / 2 - 80
        let hh = sceneSize.height / 2 - 80
        var pos: CGPoint
        repeat {
            pos = CGPoint(x: CGFloat.random(in: -hw...hw),
                          y: CGFloat.random(in: -hh...hh))
        } while pos.distance(to: playerPos) < 200  // ← distância mínima do player ao spawnar
        return pos
    }
    
    func registerEnemyKilled() {
        enemiesKilled = Swift.min(enemiesKilled + 1, totalEnemiesInWave)
    }

    // Propriedade calculada para o progresso (0.0 → 1.0)
    var waveProgress: CGFloat {
        guard totalEnemiesInWave > 0 else { return 0 }
        return CGFloat(enemiesKilled) / CGFloat(totalEnemiesInWave)
    }
}
