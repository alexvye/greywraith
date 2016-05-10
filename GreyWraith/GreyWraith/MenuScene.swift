//
//  GameStartScene.swift
//  GreyWraith
//
//  Created by Alex Vye on 2016-04-25.
//  Copyright © 2016 Alex Vye. All rights reserved.
//

import Foundation
import SpriteKit

class MenuScene: SKScene {
    
    var button: SKNode! = nil
    
    override func didMoveToView(view: SKView) {
        addButtons()
        configureScreen()
    }
    
    private func configureScreen() {
        
        backgroundColor = SKColor.whiteColor()
        
        let message = "Do you want to play a game?"
        
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.blackColor()
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Loop over all the touches in this event
        for touch: AnyObject in touches {
            // Get the location of the touch in this scene
            let location = touch.locationInNode(self)
            // Check if the location of the touch is within the button's bounds
            if button.containsPoint(location) {
                startGame()
            }
        }
    }
    
    private func addButtons() {
        // Create a simple red rectangle that's 100x44
        button = SKSpriteNode(color: SKColor.redColor(), size: CGSize(width: 100, height: 44))
        // Put it in the center of the scene
        //button.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        button.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMinY(self.frame)+100);
        
        self.addChild(button)
    }
    
    private func startGame() {
        let gameScene = GameScene(size: view!.bounds.size)
        let transition = SKTransition.fadeWithDuration(0.15)
        view!.presentScene(gameScene, transition: transition)
    }
}
