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

class MenuScene: SKScene,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate  {
    
    var playButton: SKNode! = nil
    var quitButton: SKNode! = nil
    
    //
    // for stats (unused currently)
    //
    @IBOutlet
    var tableView: UITableView!
    var items: [String] = ["Viper", "X", "Games"]
    
    //
    // config
    //
    @IBOutlet
    var playerNameTextField: UITextField!
    
    
    override func didMoveToView(view: SKView) {
        
        //
        // state
        //
        DataManager.loadData()
        
        //
        // screen
        //
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
                startGame()
            } else if self.quitButton.containsPoint(location) {
                loadStats()
            }
        }
    }
    
    private func addButtons() {
        self.playButton = SKSpriteNode(imageNamed: "playbutton.png")
        self.playButton.name = "nextButton"
        playButton.position = CGPoint(x:CGRectGetMaxX(self.frame)-100, y:CGRectGetMinY(self.frame)+300);
        playButton.zPosition = 2;
        self.addChild(playButton)
        
        self.quitButton = SKSpriteNode(imageNamed: "quitbutton.png")
        self.quitButton.name = "nextButton"
        quitButton.position = CGPoint(x:CGRectGetMaxX(self.frame)-100, y:CGRectGetMinY(self.frame)+200);
        quitButton.zPosition = 2;
        self.addChild(quitButton)
    }
    
    private func startGame() {
        
        //self.tableView.hidden = true
        
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
