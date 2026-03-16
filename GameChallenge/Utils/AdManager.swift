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

    func loadAd() {
        
        let request = Request()

        RewardedAd.load(
//            with: "ca-app-pub-3220772225574627/7610942105",
            with: "ca-app-pub-3940256099942544/1712485313",
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
            reward()
        }
        
        rewardedAd = nil
        loadAd()
    }
}
