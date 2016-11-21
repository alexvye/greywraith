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
    
    
    override func didMove(to view: SKView) {
        
        //
        // state
        //
        DataManager.loadData()
        
        //
        // screen
        //
        configureScreen()
    }

    fileprivate func configureScreen() {

        let bgImage = SKSpriteNode(imageNamed: "gwmain")
        bgImage.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        bgImage.zPosition = 1
        bgImage.size =  CGSize(width: size.width, height: size.height)
        self.addChild(bgImage)
        
        backgroundColor = SKColor.white
        
        addButtons();
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Loop over all the touches in this event
        for touch: AnyObject in touches {
            // Get the location of the touch in this scene
            let location = touch.location(in: self)
            // Check if the location of the touch is within the button's bounds
            if self.playButton.contains(location) {
                startGame()
            } else if self.quitButton.contains(location) {
                loadStats()
            }
        }
    }
    
    fileprivate func addButtons() {
        self.playButton = SKSpriteNode(imageNamed: "playbutton.png")
        self.playButton.name = "nextButton"
        playButton.position = CGPoint(x:self.frame.maxX-100, y:self.frame.minY+300);
        playButton.zPosition = 2;
        self.addChild(playButton)
        
        self.quitButton = SKSpriteNode(imageNamed: "quitbutton.png")
        self.quitButton.name = "nextButton"
        quitButton.position = CGPoint(x:self.frame.maxX-100, y:self.frame.minY+200);
        quitButton.zPosition = 2;
        self.addChild(quitButton)
    }
    
    fileprivate func startGame() {
        
        //self.tableView.hidden = true
        
        let gameScene = GameScene(size: view!.bounds.size)
        let transition = SKTransition.fade(withDuration: 0.15)
        view!.presentScene(gameScene, transition: transition)
    }
    
    fileprivate func loadStats() {

        tableView = UITableView()
        tableView?.delegate = self;
        tableView?.dataSource = self;
        
        let navRect = CGRect(x: self.frame.midX, y: 25, width: size.width/4, height: size.height*(0.85))
        tableView.frame = navRect
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view!.addSubview(tableView)
    }
    
    //
    // For stats
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        
        cell.textLabel?.text = self.items[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
