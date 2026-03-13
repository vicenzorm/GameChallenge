//
//  Animations.swift
//  SSC1
//
//  Created by Vicenzo Másera on 08/01/26.
//

import Foundation
import SpriteKit

func animatePressedButton(button: SKSpriteNode) {
    let texture = SKTexture(imageNamed: String((button.name ?? "") + "Pressed"))
    texture.filteringMode = .nearest
    button.texture = texture

}

func animatePressedToggle(toggle: SKSpriteNode, isOn: Bool) {
    if isOn {
        let texture = SKTexture(imageNamed: "toggleOn")
        texture.filteringMode = .nearest
        toggle.texture = texture
    } else {
        let texture = SKTexture(imageNamed: "toggleOff")
        texture.filteringMode = .nearest
        toggle.texture = texture
    }
}

let waitForAnimation = SKAction.wait(forDuration: 0.2)
let fadeOut = SKAction.fadeOut(withDuration: 0.5)
let specialFadeOut = SKAction.fadeOut(withDuration: 1.3)
let lastFadeOut = SKAction.fadeOut(withDuration: 2.0)
let blackScreen = SKAction.wait(forDuration: 1.0)

let sequence = SKAction.sequence([waitForAnimation, fadeOut])
let specialSequence = SKAction.sequence([waitForAnimation, specialFadeOut])
let finalSequence = SKAction.sequence([lastFadeOut, blackScreen])
