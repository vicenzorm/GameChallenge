//
//  AdManager.swift
//  GameChallenge
//
//  Created by Leonel Ferraz Hernandez on 16/03/26.
//

import GoogleMobileAds

class AdManager {

    static let shared = AdManager()
    var rewardedAd: RewardedAd?
    var onAdDismissed: (() -> Void)?
    
    private let cooldown: TimeInterval = 600
    private var lastAdTime: TimeInterval = 0
    
    func canShowAd() -> Bool{
        Date().timeIntervalSince1970 - lastAdTime >= cooldown
    }
    
    func remainingCooldown() -> TimeInterval{
        let remaining = cooldown - (Date().timeIntervalSince1970 - lastAdTime)
        return max(0, remaining)
    }
    
    func markAdUsed(){
        lastAdTime = Date().timeIntervalSince1970
    }
    
    func loadAd() {
        
        let request = Request()

        RewardedAd.load(
            with: "ca-app-pub-3220772225574627/7610942105",
//            with: "ca-app-pub-3940256099942544/1712485313",
            request: request
        ) { ad, error in
            
            if let error = error {
                print("Erro ao carregar anúncio:", error)
                return
            }

            print("Anúncio carregado!")

            self.rewardedAd = ad
            
        }
    }
    
    func showAd(from viewController: UIViewController, reward: @escaping () -> Void){
        
        guard let ad = rewardedAd else{
            print("Anúncio não está pronto")
            return
        }
        
        ad.present(from: viewController){
            print("Usuário ganhou recompensa")
            
            self.markAdUsed()
            reward()
        }
        
        rewardedAd = nil
        loadAd()
    }
}
