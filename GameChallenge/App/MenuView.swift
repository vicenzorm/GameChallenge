//
//  MenuView.swift
//  SSC1
//
//  Created by Vicenzo Másera on 07/01/26.
//

import SwiftUI
import SpriteKit

struct MenuView: UIViewRepresentable {
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        view.ignoresSiblingOrder = true
//        let scene = MenuScene(size: view.bounds.size)
//        scene.scaleMode = .aspectFill
//        view.presentScene(scene)
        return view
    }

    func updateUIView(_ uiView: SKView, context: Context) {}
}
