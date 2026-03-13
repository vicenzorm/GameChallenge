//
//  CoinSpawnSystem.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 12/03/26.
//

import SpriteKit
import CoreMotion
import Foundation

class CoinSpawnSystem {
    private var timer: TimeInterval    = 0
    private let interval: TimeInterval = 8.0
    private let maxCoins: Int          = 15
    var onSpawnCoin: ((CGPoint) -> Void)?

    func update(deltaTime: TimeInterval, activeCoins: Int, sceneSize: CGSize) {
        guard activeCoins < maxCoins else { return }
        timer -= deltaTime
        if timer <= 0 {
            timer = interval
            let hw = sceneSize.width  / 2 - 80
            let hh = sceneSize.height / 2 - 80
            onSpawnCoin?(CGPoint(x: CGFloat.random(in: -hw...hw),
                                 y: CGFloat.random(in: -hh...hh)))
        }
    }
}
