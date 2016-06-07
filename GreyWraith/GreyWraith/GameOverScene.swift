//
//  GameOverScene.swift
//  GreyWraith
//
//  Created by Alex Vye on 2016-04-25.
//  Copyright © 2016 Alex Vye. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    var playButton: SKNode! = nil
    
    init(size: CGSize, won:Bool, message:String) {
        //super.init(size: size)
        //self.showLeaderboard()
        
        super.init(size: size)
        
        // 1
        backgroundColor = SKColor.whiteColor()
        
        // 2
        let topMessage = won ? "You Won!" : "You Lose :["
        
        // 3
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = topMessage
        label.fontSize = 24
        label.fontColor = SKColor.blackColor()
        label.position = CGPoint(x: (size.width * 0.6), y: (size.height * 0.6))
        label.zPosition = 4;
        addChild(label)
        
        let label2 = SKLabelNode(fontNamed: "Chalkduster")
        label2.text = message
        label2.fontSize = 24
        label2.fontColor = SKColor.blackColor()
        label2.position = CGPoint(x: (size.width * 0.6), y: (size.height * 0.3))
        label2.zPosition = 5;
        addChild(label2)
        
        // 4
        /*
        runAction(SKAction.sequence([
            SKAction.waitForDuration(3.0),
            SKAction.runBlock() {
                // 5
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                let scene = GameScene(size: size)
                self.view?.presentScene(scene, transition:reveal)
            }
            ]))

 */
    }
    
    override func didMoveToView(view: SKView) {
        configureScreen()
    }
    
    private func configureScreen() {
        
        let bgImage = SKSpriteNode(imageNamed: "gwmain")
        bgImage.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        bgImage.zPosition = 1
        bgImage.size =  CGSize(width: size.width, height: size.height)
        self.addChild(bgImage)
        
        backgroundColor = SKColor.whiteColor()
        
        addButtons();
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Loop over all the touches in this event
        for touch: AnyObject in touches {
            // Get the location of the touch in this scene
            let location = touch.locationInNode(self)
            // Check if the location of the touch is within the button's bounds
            if self.playButton.containsPoint(location) {
                restartGame()
            }
        }
    }
    
    private func addButtons() {
        self.playButton = SKSpriteNode(imageNamed: "playbutton.png")
        self.playButton.name = "nextButton"
        playButton.position = CGPoint(x:CGRectGetMaxX(self.frame)-100, y:CGRectGetMinY(self.frame)+300);
        playButton.zPosition = 2;
        self.addChild(playButton)
    }
    
    // 6
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func restartGame() {
        let reveal = SKTransition.flipHorizontalWithDuration(0.5)
        let scene = GameScene(size: size)
        self.view?.presentScene(scene, transition:reveal)
    }
}
