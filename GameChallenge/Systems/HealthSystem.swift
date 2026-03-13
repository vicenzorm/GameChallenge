//
//  HealthSystem.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 12/03/26.
//

import SpriteKit
import CoreMotion
import Foundation

class HealthSystem {
    func update(entities: [Entity]) {
        for entity in entities {
            guard
                let health  = entity.get(HealthComponent.self),
                let barFill = health.healthBarFill
            else { continue }

            barFill.xScale = Swift.max(0, health.ratio)

            if health.ratio > 0.6      { barFill.fillColor = .green }
            else if health.ratio > 0.3 { barFill.fillColor = .yellow }
            else                       { barFill.fillColor = .red }
        }
    }
}
