//
//  GameScene.swift
//  GreyWraith
//
//  Created by Alex Vye on 2016-04-25.
//  Copyright (c) 2016 Alex Vye. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Player    : UInt32 = 0b1        // 1
    static let Monster   : UInt32 = 0b10       // 2
    static let Projectile: UInt32 = 0b100      // 3
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}
//
// Stage control values
//
var stageColourArray: [SKColor] = [SKColor.greenColor(),
                                   SKColor.yellowColor(),
                                   SKColor.redColor()]
let DEFAULT_MIN_SPEED = 2.0
let START_AMMO = 100

let AMMO_PER_STAGE = 15
let KILLS_PER_STAGE = 10
let STAGE_REDUCER = 0.8
let SPEED_FLOOR = 0.2
let CEILING_ADD = 2.0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //
    // game state
    //
    var monstersDestroyed = 0;
    var monsterEscaped = 0;
    var ammo = START_AMMO;
    var stage = 1;
    
    //
    // player
    //
    let mob = Mob.init(newType: MobType.Player)
    
    //
    // game rules
    //
    var MONSTER_WIN = 10;
    var PLAYER_WIN = 5;
    var MONSTER_MIN_SPEED = DEFAULT_MIN_SPEED
    var MONSTER_MAX_SPEED = DEFAULT_MIN_SPEED + CEILING_ADD
    
    //
    // scenery constants
    //
    var PLAYER_BOUNDARY = (CGFloat.min)
    var FLOOR = CGFloat.min;
    var CEILING = CGFloat.max;
    
    //
    // Labels for hud
    //
    let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    let playerNameLabel = SKLabelNode(fontNamed: "Chalkduster")
    let ammoLabel = SKLabelNode(fontNamed: "Chalkduster")
    let escapedLabel = SKLabelNode(fontNamed: "Chalkduster")
    
    override func didMoveToView(view: SKView) {
        //
        // reset
        //
        reset()
        
        //
        // set up plater
        //
        let player = mob.sprite
        player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size) // 1
        player.physicsBody?.dynamic = true // 2
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player // 3
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Monster // 4
        player.physicsBody?.collisionBitMask = PhysicsCategory.None //
        
        //
        // init
        //
        CEILING = size.height - 10;
        FLOOR = 10;
        
        //
        // show hud
        //
        showHud()

        //
        // setup physics
        //
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor.greenColor()
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        self.PLAYER_BOUNDARY = size.width * 0.2;

        addChild(player)
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addMonster),
                SKAction.waitForDuration(1.0)
                ])
            ))
        
        
        //let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        //backgroundMusic.autoplayLooped = true
        //addChild(backgroundMusic)

    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addMonster() {
        
        // Create sprite
        let mob = Mob.init(newType: MobType.Ghost)
        let monster = mob.sprite
        
        monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size) // 1
        monster.physicsBody?.dynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        
        // Add the monster to the scene
        addChild(monster)
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(MONSTER_MIN_SPEED), max: CGFloat(MONSTER_MAX_SPEED))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -monster.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        
        let loseAction = SKAction.runBlock() {
            self.monsterEscaped = self.monsterEscaped + 1;
            self.escapedLabel.text = String.localizedStringWithFormat("Escaped: %d", self.monsterEscaped);
            
            if(self.monsterEscaped >= self.MONSTER_WIN) {
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                let gameOverScene = GameOverScene(size: self.size, won: false)
                self.view?.presentScene(gameOverScene, transition: reveal)
                //self.submitScore()
            }
 
        }
        monster.runAction(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let player = mob.sprite
        
        runAction(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
        
        //
        // Defuct ammo
        //
        if(self.ammo > 0) {
            self.ammo = self.ammo - 1;
            
            if (self.ammo <= 0) {
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                let gameOverScene = GameOverScene(size: self.size, won: false)
                self.view?.presentScene(gameOverScene, transition: reveal)
            }
            
            ammoLabel.text = String.localizedStringWithFormat("Ammo: %d", self.ammo);
        }
        
        // 1 - Choose one of the touches to work with
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.locationInNode(self)
        
        if(touchLocation.x < self.PLAYER_BOUNDARY) { // move
            
            var down = true;
            
            print("player position is ", player.position.y)
            print("touch position is ", touchLocation.y)
            
            if(touchLocation.y > player.position.y) {
                down = false;
            }
            
            var newY = player.position.y;
            
            if(down) {
                newY = newY - 60;
            } else {
                newY = newY + 60;
            }
            
            if(newY > CEILING) {
                newY = CEILING;
            } else if(newY < FLOOR) {
                newY = FLOOR;
            }
            
            // Create the actions
            let actionMove = SKAction.moveTo(CGPoint(x: player.position.x, y: newY), duration: NSTimeInterval(CGFloat(0.2)))
            
            let moveAction = SKAction.runBlock() {
                
                NSLog("player moved")
                
            }
            
            let doneAction = SKAction.runBlock() {
                
                NSLog("player move done")
                
            }
            
            player.runAction(SKAction.sequence([actionMove, moveAction, doneAction]))
            
            
        } else {  // shoot
            
            // Set up initial location of projectile
            let projectile = SKSpriteNode(imageNamed: "fireball")
            projectile.position = player.position
        
            projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
            projectile.physicsBody?.dynamic = true
            projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
            projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
            projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
            projectile.physicsBody?.usesPreciseCollisionDetection = true
            
            // 3 Determine offset of location to projectile
            let offset = touchLocation - projectile.position
        
            // Bail out if you are shooting down or backwards
            if (offset.x < 0) { return }
        
            // OK to add now - you've double checked position
            addChild(projectile)
        
            // Get the direction of where to shoot
            let direction = offset.normalized()
        
            // Make it shoot far enough to be guaranteed off screen
            let shootAmount = direction * 1000
        
            // Add the shoot amount to the current position
            let realDest = shootAmount + projectile.position
        
            // Create the actions
            let actionMove = SKAction.moveTo(realDest, duration: 2.0)
            let actionMoveDone = SKAction.removeFromParent()
            projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        }
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
        } else if ((firstBody.categoryBitMask & PhysicsCategory.Player != 0) &&
            // unexpected nil while unwrapping an optional value here
            (secondBody.categoryBitMask & PhysicsCategory.Monster != 0)) {
            playerDidCollideWithMonster(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
        }
        
    }
    
    func projectileDidCollideWithMonster(projectile:SKSpriteNode, monster:SKSpriteNode) {

        print("projectile collide w/monster ", monster.name)
        
        projectile.removeFromParent()
        monster.removeFromParent()
        monstersDestroyed = monstersDestroyed + 1
        DataManager.updateScore(self.monstersDestroyed)
        self.updateStage()
        scoreLabel.text = String.localizedStringWithFormat("Score: %d", self.monstersDestroyed);
        if (monstersDestroyed > 30) {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    func playerDidCollideWithMonster(player:SKSpriteNode, monster:SKSpriteNode) {
        
        print("player collide w/monster")
        
        let reveal = SKTransition.flipHorizontalWithDuration(0.5)
        let gameOverScene = GameOverScene(size: self.size, won: false)
        self.view?.presentScene(gameOverScene, transition: reveal)

    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    private func showHud() {

        scoreLabel.text = String.localizedStringWithFormat("Score: %d", self.monstersDestroyed);
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = SKColor.blackColor()
        scoreLabel.position = CGPoint(x: size.width-100, y: size.height-25)
        addChild(scoreLabel)
        
        playerNameLabel.text = String.localizedStringWithFormat("%d", (DataManager.stats?.highScore)!);
        playerNameLabel.fontSize = 20
        playerNameLabel.fontColor = SKColor.blackColor()
        playerNameLabel.position = CGPoint(x: size.width/2-20, y: size.height-25)
        addChild(playerNameLabel)
        
        ammoLabel.text = String.localizedStringWithFormat("Ammo: %d", self.ammo);
        ammoLabel.fontSize = 20
        ammoLabel.fontColor = SKColor.blackColor()
        ammoLabel.position = CGPoint(x: size.width-100, y: size.height-50)
        addChild(ammoLabel)
        
        escapedLabel.text = String.localizedStringWithFormat("Escaped: %d", self.monsterEscaped);
        escapedLabel.fontSize = 20
        escapedLabel.fontColor = SKColor.blackColor()
        escapedLabel.position = CGPoint(x: 100, y: size.height-25)
        addChild(escapedLabel)
    }
    
    func updateStage() {
        
        // update high score
        playerNameLabel.text = String.localizedStringWithFormat("%d", (DataManager.stats?.highScore)!);
        
        
        //
        // update stage (ammo, colour, stage, speend (min and max)
        //
        
        //
        // check if stage should be updated
        //
        let target = (self.stage) * KILLS_PER_STAGE;
        
        print(target, self.stage, KILLS_PER_STAGE, self.monstersDestroyed )
        
        if(self.monstersDestroyed > target) {
            //
            // update stage
            //
            self.stage = self.stage + 1
            
            //
            // update ammo
            //
            self.ammo = self.ammo + AMMO_PER_STAGE
            
            //
            // update speeds
            //
            MONSTER_MIN_SPEED = MONSTER_MIN_SPEED * STAGE_REDUCER
            
            if(MONSTER_MIN_SPEED < SPEED_FLOOR) {
                MONSTER_MIN_SPEED = SPEED_FLOOR
            }
            
            MONSTER_MAX_SPEED = MONSTER_MIN_SPEED + CEILING_ADD
            
            //
            // Update colours
            //
            var index = 0;
            
            print(self.stage, stageColourArray.count)
            if(self.stage <= stageColourArray.count) {
                
                index  = self.stage - 1;
            } else {
                let remainder = self.stage %  stageColourArray.count
                index = remainder - 1;
            }
            //Int remainder = stageColourArray.count
            self.backgroundColor = stageColourArray[index]
            
            
            //
            // Update monsters
            //
            // (maybe at later stages add new monsters)
        }
    }
    
    func reset() {
        
        MONSTER_MIN_SPEED = DEFAULT_MIN_SPEED
        MONSTER_MAX_SPEED = DEFAULT_MIN_SPEED + CEILING_ADD
        
        self.monstersDestroyed = 0
        self.ammo = START_AMMO
        self.monsterEscaped = 0
        self.stage = 1
    }
}
