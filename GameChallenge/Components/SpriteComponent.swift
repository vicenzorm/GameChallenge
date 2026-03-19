//
//  SpriteComponent.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 12/03/26.
//

import SpriteKit
import Foundation

class SpriteComponent: Component {
    
    var isSpecialAttack: Bool = false
    
    var isFlashing: Bool = false

    // Movimento
    var downTextures:  [SKTexture]
    var upTextures:    [SKTexture]
    var leftTextures:  [SKTexture]
    var rightTextures: [SKTexture]

    // Idle (1 frame por direção)
    var idleDown:  SKTexture
    var idleUp:    SKTexture
    var idleLeft:  SKTexture
    var idleRight: SKTexture

    // Ataque direcional (botão A — frontal)
    var attackDownTextures:  [SKTexture]
    var attackUpTextures:    [SKTexture]
    var attackLeftTextures:  [SKTexture]
    var attackRightTextures: [SKTexture]

    // Ataque especial (botão B — mantém o array genérico para o especial omnidirecional)
    var attackTextures: [SKTexture]

    // Estado
    var currentDirection: Direction = .down
    var lastDirection:    Direction = .down
    var isMoving:    Bool = false
    var isAttacking: Bool = false

    // Controle de tempo
    var animationSpeed: TimeInterval = 0.1
    var currentFrame:   Int          = 0
    var lastFrameTime:  TimeInterval = 0

    enum Direction: String {
        case down, up, left, right
    }

    init(
        downTextures:  [SKTexture], upTextures:   [SKTexture],
        leftTextures:  [SKTexture], rightTextures: [SKTexture],
        idleDown:  SKTexture, idleUp:   SKTexture,
        idleLeft:  SKTexture, idleRight: SKTexture,
        attackDownTextures:  [SKTexture], attackUpTextures:   [SKTexture],
        attackLeftTextures:  [SKTexture], attackRightTextures: [SKTexture],
        attackTextures: [SKTexture]
    ) {
        self.downTextures  = downTextures;  self.upTextures    = upTextures
        self.leftTextures  = leftTextures;  self.rightTextures = rightTextures
        self.idleDown  = idleDown;  self.idleUp   = idleUp
        self.idleLeft  = idleLeft;  self.idleRight = idleRight
        self.attackDownTextures  = attackDownTextures
        self.attackUpTextures    = attackUpTextures
        self.attackLeftTextures  = attackLeftTextures
        self.attackRightTextures = attackRightTextures
        self.attackTextures = attackTextures
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // Retorna os frames de ataque direcional corretos para a direção atual
    var currentAttackTextures: [SKTexture] {
        switch lastDirection {
        case .down:  return attackDownTextures
        case .up:    return attackUpTextures
        case .left:  return attackLeftTextures
        case .right: return attackRightTextures
        }
    }

    // Retorna a textura idle para a última direção
    var currentIdleTexture: SKTexture {
        switch lastDirection {
        case .down:  return idleDown
        case .up:    return idleUp
        case .left:  return idleLeft
        case .right: return idleRight
        }
    }
}
