import SpriteKit
import Foundation

class EnemyAISystem {

    // ── Separação mínima entre inimigos (evita empilhamento) ──────────
    // Aumente para inimigos mais espalhados, diminua para hordas mais densas
    private let separationRadius: CGFloat = 45
    private let separationForce:  CGFloat = 0.6   // 0 = sem separação, 1 = máxima

    func update(
        enemies: [Entity],
        playerEntity: Entity,
        deltaTime: TimeInterval,
        currentTime: TimeInterval,
        onEnemyShoot: ((Entity, CGVector) -> Void)?
    ) {
        guard let playerTransform = playerEntity.get(TransformComponent.self) else { return }
        let playerPos = playerTransform.node.position

        for enemy in enemies {
            guard
                let transform = enemy.get(TransformComponent.self),
                let movement  = enemy.get(MovementComponent.self),
                let enemyComp = enemy.get(EnemyComponent.self),
                let health    = enemy.get(HealthComponent.self),
                health.isAlive
            else { continue }

            let pos      = transform.node.position
            let toPlayer = CGVector(dx: playerPos.x - pos.x, dy: playerPos.y - pos.y)
            let dist     = sqrt(toPlayer.dx * toPlayer.dx + toPlayer.dy * toPlayer.dy)
            let dir      = dist > 0
                ? CGVector(dx: toPlayer.dx / dist, dy: toPlayer.dy / dist)
                : .zero

            // ── Força de separação: empurra inimigos para fora uns dos outros ──
            // Evita que todos se empilhem no mesmo ponto, tornando o jogo mais legível
            var separationVec = CGVector.zero
            for other in enemies {
                guard other.id != enemy.id,
                      let otherTransform = other.get(TransformComponent.self)
                else { continue }
                let diff = CGVector(
                    dx: pos.x - otherTransform.node.position.x,
                    dy: pos.y - otherTransform.node.position.y
                )
                let d = sqrt(diff.dx * diff.dx + diff.dy * diff.dy)
                if d < separationRadius && d > 0 {
                    // Quanto mais perto, mais forte o empurrão
                    let push = (separationRadius - d) / separationRadius
                    separationVec.dx += (diff.dx / d) * push
                    separationVec.dy += (diff.dy / d) * push
                }
            }

            if enemyComp.type.canShoot {
                updateShooter(
                    enemy: enemy,
                    enemyComp: enemyComp,
                    movement: movement,
                    dir: dir,
                    dist: dist,
                    separation: separationVec,
                    currentTime: currentTime,
                    onEnemyShoot: onEnemyShoot
                )
            } else {
                updateMelee(
                    enemy: enemy,
                    enemyComp: enemyComp,
                    movement: movement,
                    dir: dir,
                    dist: dist,
                    separation: separationVec,
                    currentTime: currentTime,
                    playerPos: playerPos,
                    pos: pos
                )
            }
        }
    }

    // MARK: - Melee AI (weak / normal / strong)

    private func updateMelee(
        enemy: Entity,
        enemyComp: EnemyComponent,
        movement: MovementComponent,
        dir: CGVector,
        dist: CGFloat,
        separation: CGVector,
        currentTime: TimeInterval,
        playerPos: CGPoint,
        pos: CGPoint
    ) {
        // ── Comportamento por tipo ─────────────────────────────────────────
        switch enemyComp.type {

        case .strong:
            // Strong: perseguição direta agressiva, sem desvio
            // É lento mas não hesita — sempre em linha reta
            let vel = CGVector(
                dx: dir.dx * movement.speed + separation.dx * separationForce,
                dy: dir.dy * movement.speed + separation.dy * separationForce
            )
            movement.velocity = vel

        case .normal:
            // Normal: perseguição com leve zigzag temporal para ser imprevisível
            // Troca de fase a cada 1.8s, alternando desvio lateral esquerdo/direito
            let zigzagAmplitude: CGFloat = 55   // ← quanto desvia lateralmente
            let zigzagPeriod: TimeInterval = 1.8  // ← velocidade do ciclo
            let phase = sin(currentTime / zigzagPeriod * .pi * 2)
            let lateral = CGVector(dx: -dir.dy, dy: dir.dx)  // perpendicular ao dir
            let vel = CGVector(
                dx: dir.dx * movement.speed + lateral.dx * phase * zigzagAmplitude
                    + separation.dx * separationForce,
                dy: dir.dy * movement.speed + lateral.dy * phase * zigzagAmplitude
                    + separation.dy * separationForce
            )
            movement.velocity = vel

        default:
            // Weak: perseguição direta simples com separação
            let vel = CGVector(
                dx: dir.dx * movement.speed + separation.dx * separationForce,
                dy: dir.dy * movement.speed + separation.dy * separationForce
            )
            movement.velocity = vel
        }
    }

    // MARK: - Shooter / Boss AI

    private func updateShooter(
        enemy: Entity,
        enemyComp: EnemyComponent,
        movement: MovementComponent,
        dir: CGVector,
        dist: CGFloat,
        separation: CGVector,
        currentTime: TimeInterval,
        onEnemyShoot: ((Entity, CGVector) -> Void)?
    ) {
        let preferred = enemyComp.type.preferredRange
        let isBoss = enemyComp.type == .boss

        if dist > preferred {
            // Longe demais: se aproxima
            movement.velocity = CGVector(
                dx: dir.dx * movement.speed + separation.dx * separationForce,
                dy: dir.dy * movement.speed + separation.dy * separationForce
            )
        } else if dist < preferred * 0.65 {
            // Perto demais: recua
            movement.velocity = CGVector(
                dx: -dir.dx * movement.speed + separation.dx * separationForce,
                dy: -dir.dy * movement.speed + separation.dy * separationForce
            )
        } else {
            // Na faixa ideal: strafe lateral para não ficar parado
            // Boss strafa mais rápido e muda de lado com mais frequência
            let strafePeriod: TimeInterval = isBoss ? 1.2 : 2.0  // ← ciclo de mudança de lado
            let strafeSpeed:  CGFloat      = isBoss ? movement.speed * 0.7 : movement.speed * 0.5
            let phase = sin(currentTime / strafePeriod * .pi * 2)
            let lateral = CGVector(dx: -dir.dy, dy: dir.dx)
            movement.velocity = CGVector(
                dx: lateral.dx * phase * strafeSpeed + separation.dx * separationForce,
                dy: lateral.dy * phase * strafeSpeed + separation.dy * separationForce
            )
        }

        // ── Tiro ────────────────────────────────────────────────────────────
        if currentTime - enemyComp.lastShotTime >= enemyComp.type.shootCooldown {
            enemyComp.lastShotTime = currentTime

            if isBoss {
                // Boss: disparo em leque (3 projéteis espalhados ±15°)
                // Aumente o ângulo ou a quantidade para um boss mais difícil
                let spreadAngles: [CGFloat] = [-0.26, 0, 0.26]  // ±15° em radianos
                let baseAngle = atan2(dir.dy, dir.dx)
                for offset in spreadAngles {
                    let a = baseAngle + offset
                    let spreadDir = CGVector(dx: cos(a), dy: sin(a))
                    onEnemyShoot?(enemy, spreadDir)
                }
            } else {
                // Shooter normal: um único projétil
                onEnemyShoot?(enemy, dir)
            }
        }
    }
}
