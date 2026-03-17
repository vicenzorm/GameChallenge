//
//  SkeletonSpriteComponent.swift
//  GameChallenge
//
//  Created by Bernardo Garcia Fensterseifer on 17/03/26.
//

import SpriteKit
import Foundation

// Controla as animações do skeleton: walk (loop), atk (one-shot ao colidir),
// dmg (one-shot ao tomar dano), die (one-shot + remove nó).
// idle existe no asset mas não é usado — skeleton sempre persegue.
class SkeletonSpriteComponent: Component {

    let walkTextures:  [SKTexture]   // skeleton_walk_1-10
    let atkTextures:   [SKTexture]   // skeleton_atk_1-10
    let dmgTextures:   [SKTexture]   // skeleton_damage_1-5
    let dieTextures:   [SKTexture]   // skeleton_die_1-12

    enum State { case walk, atk, dmg, die }
    var state: State = .walk

    var currentFrame:  Int          = 0
    var lastFrameTime: TimeInterval = 0

    // Velocidades por estado (segundos por frame)
    var walkSpeed:  TimeInterval = 0.10
    var atkSpeed:   TimeInterval = 0.08  // ataque rápido
    var dmgSpeed:   TimeInterval = 0.10
    var dieSpeed:   TimeInterval = 0.09

    // Evita triggar death mais de uma vez
    var deathStarted: Bool = false

    // Evita triggar atk enquanto já está atacando
    var isPlayingOneShot: Bool = false

    init(walkTextures:  [SKTexture],
         atkTextures:   [SKTexture],
         dmgTextures:   [SKTexture],
         dieTextures:   [SKTexture]) {
        self.walkTextures  = walkTextures
        self.atkTextures   = atkTextures
        self.dmgTextures   = dmgTextures
        self.dieTextures   = dieTextures
    }

    required init?(coder: NSCoder) { fatalError() }

    var currentSpeed: TimeInterval {
        switch state {
        case .walk: return walkSpeed
        case .atk:  return atkSpeed
        case .dmg:  return dmgSpeed
        case .die:  return dieSpeed
        }
    }
}
