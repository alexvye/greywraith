//
//  GameViewController.swift
//  GreyWraith
//
//  Created by Alex Vye on 2016-04-25.
//  Copyright (c) 2016 Alex Vye. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController  {
    
    var score: Int = 0 // Stores the score
    
    var gcEnabled = Bool() // Stores if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Stores the default leaderboardID

    override func viewDidLoad() {
        super.viewDidLoad()

        //
        // scene
        //
        let sceneView = view as! SKView
        // sceneView.showsFPS = true
        // sceneView.showsNodeCount = true
        sceneView.ignoresSiblingOrder = true
        
        let scene = MenuScene(size: view.bounds.size)
        scene.scaleMode = .ResizeFill
        sceneView.presentScene(scene)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
