//
//  CGPoint+Distance.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 12/03/26.
//

import SpriteKit
import CoreMotion
import Foundation

// MARK: - Helpers
extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        let dx = x - other.x; let dy = y - other.y
        return sqrt(dx*dx + dy*dy)
    }
}
