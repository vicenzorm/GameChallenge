//
//  GameCenterManager.swift
//  GameChallenge
//
//  Created by Leonel Ferraz Hernandez on 19/03/26.
//

import Foundation
import GameKit
import UIKit

class GameCenterManager: NSObject, GKGameCenterControllerDelegate {
    
    static let shared = GameCenterManager()
    
    private(set) var isAuthenticated = false
    
    /// Returns the top view controller for presenting modal UI (works with SwiftUI/scene-based apps).
    private func topViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first else {
            return nil
        }
        var vc = window.rootViewController
        while let presented = vc?.presentedViewController { vc = presented }
        return vc
    }
    
    func authenticatePlayer() {
        let localPlayer = GKLocalPlayer.local
        
        localPlayer.authenticateHandler = { [weak self] (vc, error) in
            DispatchQueue.main.async {
                if let viewController = vc {
                    self?.topViewController()?.present(viewController, animated: true)
                    return
                }
                if localPlayer.isAuthenticated {
                    self?.isAuthenticated = true
                    print("Player logado")
                } else {
                    print("Falha de login")
                }
            }
        }
    }
    
    func submitScore(floor: Int){
        guard isAuthenticated else { return }
        
        let leaderboardID = "highest_floor"
        
        GKLeaderboard.submitScore(floor, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [leaderboardID]){error in
            if let error = error{
                print("Erro ao enviar score: \(error.localizedDescription)")
            }else{
                print("Recorde do andar \(floor) enviado")
            }
        }
    }
    
    /// Presents the Game Center leaderboard. Pass a view controller when calling from a scene (e.g. `view?.window?.rootViewController`) for best compatibility.
    func showLeaderboard(from viewController: UIViewController? = nil) {
        guard GKLocalPlayer.local.isAuthenticated else {
            print("Game Center: player not authenticated, cannot show leaderboard")
            return
        }
        let presenter = viewController ?? topViewController()
        guard let presenter else {
            print("Game Center: no view controller to present leaderboard")
            return
        }
        isAuthenticated = true
        let gcVC = GKGameCenterViewController(state: .leaderboards)
        gcVC.gameCenterDelegate = self
        presenter.present(gcVC, animated: true)
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
    
}
