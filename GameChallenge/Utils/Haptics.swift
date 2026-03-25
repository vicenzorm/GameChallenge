//
//  Haptics.swift
//  GameChallenge
//
//  Created by Lorenzo Fortes on 23/03/26.
//

import Foundation
import UIKit

enum HapticFeedbackStrength {
    case light
    case medium
    case heavy
    case soft
    case rigid
    
    fileprivate var style: UIImpactFeedbackGenerator.FeedbackStyle {
        switch self {
        case .light, .soft:
            return .light
        case .medium:
            return .medium
        case .heavy, .rigid:
            return .heavy
        }
    }
}

func vibrate(with strength: HapticFeedbackStrength) {
    if AppManager.shared.hapticsEnabled {
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: strength.style)
            generator.prepare()
            generator.impactOccurred()
        }
    }
}
