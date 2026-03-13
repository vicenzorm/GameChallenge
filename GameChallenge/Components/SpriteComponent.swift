//
//  SpriteComponent.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 12/03/26.
//

import SpriteKit
import Foundation

// Sprite animation component
class SpriteComponent: Component {
    // Textures para cada direção
    var downTextures: [SKTexture]
    var upTextures: [SKTexture]
    var leftTextures: [SKTexture]
    var rightTextures: [SKTexture]
    var attackTextures: [SKTexture]
    
    // Estado atual
    var currentDirection: Direction = .down
    var lastDirection: Direction = .down
    var isMoving: Bool = false
    var isAttacking: Bool = false
    
    // Animação - CONTROLE DE TEMPO
    var animationSpeed: TimeInterval = 0.1  // segundos por frame (mais lento)
    var currentFrame: Int = 0
    var lastFrameTime: TimeInterval = 0      // tempo do último frame
    
    enum Direction: String {
        case down, up, left, right
        
        var textureArrayName: String {
            return "\(self.rawValue)_textures"
        }
    }
    
    init(downTextures: [SKTexture], upTextures: [SKTexture],
         leftTextures: [SKTexture], rightTextures: [SKTexture],
         attackTextures: [SKTexture]) {
        self.downTextures = downTextures
        self.upTextures = upTextures
        self.leftTextures = leftTextures
        self.rightTextures = rightTextures
        self.attackTextures = attackTextures
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
