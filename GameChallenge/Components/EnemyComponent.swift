//
//  EnemyComponent.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 12/03/26.
//

import SpriteKit
import Foundation

// Enemy-specific
class EnemyComponent: Component {
    enum EnemyType {
        case weak, normal, strong

        var radius: CGFloat {
            switch self {
            case .weak: return 14
            case .normal: return 22
            case .strong: return 32
            }
        }

        var maxHealth: CGFloat {
            switch self {
            case .weak: return 30
            case .normal: return 80
            case .strong: return 200
            }
        }

        var speed: CGFloat {
            switch self {
            case .weak: return 90
            case .normal: return 65
            case .strong: return 45
            }
        }

        var damage: CGFloat {
            switch self {
            case .weak: return 5
            case .normal: return 12
            case .strong: return 25
            }
        }

        // Points toward special charge when killed
        var specialPoints: Int {
            switch self {
            case .weak: return 1
            case .normal: return 2  // needs ceil(5/2)=3 kills
            case .strong: return 5  // 1 kill = 5 pts (threshold 5)
            }
        }
    }

    var type: EnemyType
    init(type: EnemyType) { self.type = type }
}
