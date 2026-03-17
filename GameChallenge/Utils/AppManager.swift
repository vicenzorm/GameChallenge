//
//  UserConfig.swift
//  SSC1
//
//  Created by Vicenzo Másera on 08/01/26.
//

import UIKit

class AppManager {
    static let shared: AppManager = AppManager()
    
    var soundEnabled: Bool
    var appFont = "DungeonFont"
    var secondaryFont = "PressStart2P-Regular"
    
    
    init() {
        self.soundEnabled = true
    }
    
    func toggleSound() {
        soundEnabled.toggle()
    }
    
    
    func fontSize(type: FontType, screenSize: CGSize) -> CGFloat {
        let referenceDimension = min(screenSize.width, screenSize.height)
        
        switch type {
        case .title:
            return referenceDimension * 0.12
        case .subtitle:
            return referenceDimension * 0.08
        case .label:
            return referenceDimension * 0.05
        case .labelMini:
            return referenceDimension * 0.04
        case .info:
            return referenceDimension * 0.035
        case .minor:
            return referenceDimension * 0.025
        }
    }
    
    func buttonSize(screenSize: CGSize, isTitle: Bool = false) -> CGSize {
        let width = screenSize.width
        let buttonWidth = isTitle ? width * 0.25 : width * 0.10
        return CGSize(width: buttonWidth, height: buttonWidth * 0.5)
    }
}

enum FontType {
    case title, subtitle, label, info, minor, labelMini
}
