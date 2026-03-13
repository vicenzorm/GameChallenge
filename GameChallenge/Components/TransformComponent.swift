//
//  TransformComponent.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 12/03/26.
//

import SpriteKit
import Foundation

// Visual representation (SpriteKit node)
class TransformComponent: Component {
    var node: SKNode
    init(node: SKNode) { self.node = node }
}
