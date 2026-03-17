//
//  EnemyComponent.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 12/03/26.
//

import SpriteKit
import Foundation

class EnemyComponent: Component {
    enum EnemyType {
        case weak, normal, strong, shooter, boss

        var maxHealth: CGFloat {
            switch self {
            case .weak:    return 30
            case .normal:  return 70
            case .strong:  return 150
            case .shooter: return 50
            case .boss:    return 300
            }
        }

        var speed: CGFloat {
            switch self {
            case .weak:    return 90
            case .normal:  return 70
            case .strong:  return 50
            case .shooter: return 55
            case .boss:    return 35
            }
        }

        var damage: CGFloat {
            switch self {
            case .weak:    return 8
            case .normal:  return 14
            case .strong:  return 22
            case .shooter: return 10
            case .boss:    return 30
            }
        }

        var radius: CGFloat {
            switch self {
            case .weak:    return 24
            case .normal:  return 34
            case .strong:  return 50
            case .shooter: return 28
            case .boss:    return 90
            }
        }

        var specialPoints: Int {
            switch self {
            case .weak:    return 1
            case .normal:  return 2
            case .strong:  return 4
            case .shooter: return 2
            case .boss:    return 10
            }
        }

        // Se o tipo consegue atirar
        var canShoot: Bool {
            switch self {
            case .shooter, .boss: return true
            default: return false
            }
        }

        // Intervalo entre tiros (segundos)
        var shootCooldown: TimeInterval {
            switch self {
            case .shooter: return 2.0
            case .boss:    return 2.5
            default:       return .infinity
            }
        }

        // Alcance mínimo para atirar (fica longe do player)
        var preferredRange: CGFloat {
            switch self {
            case .shooter: return 220
            case .boss:    return 220
            default:       return 0
            }
        }
    }

    let type: EnemyType
    var spriteComp: EnemySpriteComponent?
    
    // Throttle para o som de ataque — evita repetição a cada frame de colisão
    var canPlayAttackSound: Bool = true
    var attackSoundCooldown: TimeInterval = 0

    // Controle de tiro — só usado por .shooter e .boss
    var lastShotTime: TimeInterval = 0

    init(type: EnemyType) {
        self.type = type
    }
}
