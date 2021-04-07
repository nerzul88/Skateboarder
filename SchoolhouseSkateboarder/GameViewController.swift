//
//  GameViewController.swift
//  SchoolhouseSkateboarder
//
//  Created by Александр Касьянов on 02.04.2021.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            
            if let scene = SKScene(fileNamed: "GameScene") {
                
                scene.scaleMode = .aspectFill
                
                let width = view.bounds.width
                let height = view.bounds.height
                scene.size = CGSize(width: width, height: height)
                
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
