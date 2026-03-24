//
//  OnboardingView.swift
//  GameChallenge
//
//  Created by Bernardo Garcia Fensterseifer on 23/03/26.
//


//
//  OnboardingView.swift
//  GameChallenge
//

import SwiftUI
import SpriteKit

struct OnboardingView: View {

    @State private var goToMenu = false

    var scene: SKScene {
        let s = OnboardingScene()
        s.size      = UIScreen.main.bounds.size
        s.scaleMode = .aspectFill
        s.onFinished = {
            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
            goToMenu = true
        }
        return s
    }

    var body: some View {
        if goToMenu {
            MenuView()
                .ignoresSafeArea()
        } else {
            SpriteView(scene: scene)
                .ignoresSafeArea()
        }
    }
}