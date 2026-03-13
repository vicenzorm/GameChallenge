//
//  ProjectileComponent.swift
//  GameChallenge
//
//  Created by Vicenzo Másera on 13/03/26.
//
import SpriteKit

class ProjectileComponent: Component {
    var damage: CGFloat
    var direction: CGVector
    var speed: CGFloat
    var lifetime: TimeInterval 
    
    init(damage: CGFloat, direction: CGVector, speed: CGFloat, lifetime: TimeInterval = 2.0) {
        self.damage = damage
        self.direction = direction
        self.speed = speed
        self.lifetime = lifetime
    }
}
