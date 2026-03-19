//
//  BoxComponent.swift
//  GameChallenge
//
//  Created by Bernardo Garcia Fensterseifer on 16/03/26.
//

import Foundation
import SpriteKit

// Marker component — identifies an entity as an indestructible box.
class BoxComponent: Component {
    enum ObstacleType: CaseIterable {
        case box, barrel, treasure, vase, firecamp
        
        var assetName: String {
            switch self {
            case .box:      return "box_sprite"
            case .barrel:   return "barrel_sprite"
            case .treasure: return "treasure_sprite"
            case .vase:     return "vase_sprite"
            case .firecamp: return "firecamp_sprite_1"
            }
        }
        
        var loopAnimation: SKAction? {
            switch self {
            case .firecamp:
                let textures = (1...6).map { i -> SKTexture in
                    let t = SKTexture(imageNamed: "firecamp_sprite_\(i)")
                    t.filteringMode = .nearest
                    return t
                }
                return .repeatForever(.animate(with: textures, timePerFrame: 0.16))
            default:
                return nil
            }
        }
    }
    
    let obstacleType: ObstacleType
    
    init(type: ObstacleType = .box) {
        self.obstacleType = type
    }
}
