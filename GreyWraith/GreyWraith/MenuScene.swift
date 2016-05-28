//
//  GameStartScene.swift
//  GreyWraith
//
//  Created by Alex Vye on 2016-04-25.
//  Copyright © 2016 Alex Vye. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class MenuScene: SKScene,UITableViewDelegate, UITableViewDataSource  {
    
    var playButton: SKNode! = nil
    var statsButton: SKNode! = nil
    var configButton: SKNode! = nil
    
    //
    // for stats
    //
    @IBOutlet
    var tableView: UITableView!
    var items: [String] = ["Viper", "X", "Games"]
    
    override func didMoveToView(view: SKView) {
        //addButtons()
        configureScreen()
    }
    
    private func configureScreen() {
        
        //self.scaleMode = SKSceneScaleMode.ResizeFill
        
        let bgImage = SKSpriteNode(imageNamed: "gwmain")
        bgImage.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        bgImage.zPosition = 1
        bgImage.size =  CGSize(width: size.width, height: size.height)
        
        
        self.addChild(bgImage)
        
        backgroundColor = SKColor.whiteColor()
        
        //let message = "Do you want to play a game?"
        /*
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.blackColor()
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        label.zPosition = 2
        addChild(label)
        */
        addButtons();
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Loop over all the touches in this event
        for touch: AnyObject in touches {
            // Get the location of the touch in this scene
            let location = touch.locationInNode(self)
            // Check if the location of the touch is within the button's bounds
            if self.playButton.containsPoint(location) {
                startGame()
            } else if self.statsButton.containsPoint(location) {
                loadStats()
            }
        }
    }
    
    private func addButtons() {
        // Create a simple red rectangle that's 100x44
        playButton = SKSpriteNode(color: SKColor.greenColor(), size: CGSize(width: 50, height: 30))
        // Put it in the center of the scene
        //button.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        playButton.position = CGPoint(x:CGRectGetMaxX(self.frame)-100, y:CGRectGetMinY(self.frame)+300);
        playButton.zPosition = 2;
        
        statsButton = SKSpriteNode(color: SKColor.grayColor(), size: CGSize(width: 50, height: 30))
        // Put it in the center of the scene
        //button.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        statsButton.position = CGPoint(x:CGRectGetMaxX(self.frame)-100, y:CGRectGetMinY(self.frame)+200);
        statsButton.zPosition = 2;
        
        configButton = SKSpriteNode(color: SKColor.redColor(), size: CGSize(width: 50, height: 30))
        // Put it in the center of the scene
        //button.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        configButton.position = CGPoint(x:CGRectGetMaxX(self.frame)-100, y:CGRectGetMinY(self.frame)+100);
        configButton.zPosition = 2;
        
        self.addChild(playButton)
        self.addChild(statsButton)
        self.addChild(configButton)
    }
    
    private func startGame() {
        
        self.tableView.hidden = true
        
        let gameScene = GameScene(size: view!.bounds.size)
        let transition = SKTransition.fadeWithDuration(0.15)
        view!.presentScene(gameScene, transition: transition)
    }
    
    private func loadStats() {

        tableView = UITableView()
        tableView?.delegate = self;
        tableView?.dataSource = self;
        
        let navRect = CGRectMake(CGRectGetMidX(self.frame), 25, size.width/4, size.height*(0.85))
        tableView.frame = navRect
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view!.addSubview(tableView)
    }
    
    //
    // For stats
    //
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        cell.textLabel?.text = self.items[indexPath.row]
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
