//
//  MovementComponent.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 12/03/26.
//

import SpriteKit
import Foundation

// Movement
class MovementComponent: Component {
    var speed: CGFloat
    var velocity: CGVector = .zero

    init(speed: CGFloat) { self.speed = speed }
}
