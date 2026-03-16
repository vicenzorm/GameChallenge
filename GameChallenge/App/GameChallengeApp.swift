//
//  GameChallengeApp.swift
//  GameChallenge
//
//  Created by Vicenzo Másera on 11/03/26.
//

import SwiftUI
import GoogleMobileAds

@main
struct GameChallengeApp: App {
    
    init() {
        MobileAds.shared.start(completionHandler: nil)
    }
    
    var body: some Scene {
        WindowGroup {
            MenuView()
                .ignoresSafeArea()
        }
    }
}
