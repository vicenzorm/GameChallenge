//
//  SKNode+Spring.swift
//  GameChallenge
//
//  Created by Bernardo Garcia Fensterseifer on 24/03/26.
//

//
//  SKNode+SpringTap.swift
//

import SpriteKit

extension SKNode {
    /// Animação spring de toque: encolhe → estica → volta ao normal.
    /// O completion é chamado no pico do bounce para resposta imediata.
    func springTap(completion: (() -> Void)? = nil) {
        removeAction(forKey: "springTap")
        let squeeze = SKAction.scale(to: 0.82, duration: 0.08)
        squeeze.timingMode = .easeIn
        let bounce = SKAction.scale(to: 1.12, duration: 0.12)
        bounce.timingMode = .easeOut
        let settle = SKAction.scale(to: 1.0, duration: 0.10)
        settle.timingMode = .easeInEaseOut

        run(.sequence([
            squeeze,
            .run { completion?() },
            bounce,
            settle
        ]), withKey: "springTap")
    }
}
