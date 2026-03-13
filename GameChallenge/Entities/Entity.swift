//
//  Entity.swift
//  POC-2DGame
//
//  Created by Bernardo Garcia Fensterseifer on 12/03/26.
//

import SpriteKit
import Foundation

// Entity is just a container of components
class Entity {
    let id: UUID = UUID()
    var components: [ObjectIdentifier: Component] = [:]

    func add<T: Component>(_ component: T) {
        components[ObjectIdentifier(T.self)] = component
    }

    func get<T: Component>(_ type: T.Type) -> T? {
        return components[ObjectIdentifier(type)] as? T
    }

    func remove<T: Component>(_ type: T.Type) {
        components.removeValue(forKey: ObjectIdentifier(type))
    }
}
