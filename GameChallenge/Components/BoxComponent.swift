//
//  BoxComponent.swift
//  GameChallenge
//
//  Created by Bernardo Garcia Fensterseifer on 16/03/26.
//

import Foundation

// Marker component — identifies an entity as an indestructible box.
class BoxComponent: Component {
    enum ObstacleType: CaseIterable {
        case box, barrel, treasure, vase

        var assetName: String {
            switch self {
            case .box:      return "box_sprite"
            case .barrel:   return "barrel_sprite"
            case .treasure: return "treasure_sprite"
            case .vase:     return "vase_sprite"
            }
        }
    }

    let obstacleType: ObstacleType

    init(type: ObstacleType = .box) {
        self.obstacleType = type
    }
}
