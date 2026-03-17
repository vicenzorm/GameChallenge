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
    var hapticsEnabled: Bool
    var sFXEnabled: Bool
    var appFont = "DungeonFont"
    var secondaryFont = "PressStart2P-Regular"
    
    
    init() {
        self.soundEnabled = true
        self.sFXEnabled = true
        self.hapticsEnabled = true
    }
    
    func toggleSound() {
        soundEnabled.toggle()
    }
    
    func toggleHaptics() {
        hapticsEnabled.toggle()
    }
    
    func toggleSFX() {
        sFXEnabled.toggle()
    }
}

