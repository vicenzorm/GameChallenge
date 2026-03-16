//
//  InputComponent.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 12/03/26.
//

import SpriteKit
import Foundation

// Input state (populated by InputSystem)
class InputComponent: Component {
    var movementDirection: CGVector = .zero  // normalized
    var attackDirection: CGVector = .zero
    
    var aimDirection: CGVector = .zero
    var isAiming: Bool = false
    
    var attackPressed: Bool = false
    var specialPressed: Bool = false
}
