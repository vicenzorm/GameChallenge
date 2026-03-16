//
//  EnemySpriteComponent.swift
//  GameChallenge
//
//  Created by Bernardo Garcia Fensterseifer on 16/03/26.
//

import SpriteKit
import Foundation

// Controla as 3 animações de um inimigo: fly (loop), dmg (one-shot), death (one-shot + remove)
class EnemySpriteComponent: Component {

    let flyTextures:   [SKTexture]
    let dmgTextures:   [SKTexture]
    let deathTextures: [SKTexture]

    enum State { case fly, dmg, death }
    var state: State = .fly

    var currentFrame:  Int          = 0
    var lastFrameTime: TimeInterval = 0

    // Velocidades separadas por estado — dmg mais lento para ser visível
    var flyAnimationSpeed:   TimeInterval = 0.15
    var dmgAnimationSpeed:   TimeInterval = 0.15
    var deathAnimationSpeed: TimeInterval = 0.15

    var deathStarted: Bool = false

    init(flyTextures: [SKTexture], dmgTextures: [SKTexture], deathTextures: [SKTexture]) {
        self.flyTextures   = flyTextures
        self.dmgTextures   = dmgTextures
        self.deathTextures = deathTextures
    }

    // Retorna o animationSpeed correto pro estado atual
    var currentAnimationSpeed: TimeInterval {
        switch state {
        case .fly:   return flyAnimationSpeed
        case .dmg:   return dmgAnimationSpeed
        case .death: return deathAnimationSpeed
        }
    }

    required init?(coder: NSCoder) { fatalError() }
}
