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
var stageColourArray: [SKColor] = [SKColor.green,
                                   SKColor.yellow,
                                   SKColor.red]
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
    var monsterHp = [String: Int]()
    
    //
    // player
    //
    let playerMob = Mob.init(newType: MobType.player)

    
    //
    // game rules
    //
    var MONSTER_WIN = 10;
    var PLAYER_WIN = 5;
    var MONSTER_MIN_SPEED = DEFAULT_MIN_SPEED
    var MONSTER_MAX_SPEED = DEFAULT_MIN_SPEED + CEILING_ADD
    var VICTORY = 30
    
    //
    // scenery constants
    //
    var PLAYER_BOUNDARY = (CGFloat.leastNormalMagnitude)
    var FLOOR = CGFloat.leastNormalMagnitude;
    var CEILING = CGFloat.greatestFiniteMagnitude;
    
    //
    // Labels for hud
    //
    let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    let playerNameLabel = SKLabelNode(fontNamed: "Chalkduster")
    let ammoLabel = SKLabelNode(fontNamed: "Chalkduster")
    let escapedLabel = SKLabelNode(fontNamed: "Chalkduster")
    let stageLabel = SKLabelNode(fontNamed: "Chalkduster")
    
    //
    // textures
    //
    var shelobWalkingFrames : [SKTexture]!
    var greyFrames : [SKTexture]!
    var explosionFrames : [SKTexture]!
    let atlas = SKTextureAtlas(named: "sprites")
    
    override func didMove(to view: SKView) {
        //
        // reset
        //
        reset()
        
        //
        // set up plater
        //
        let player = playerMob.sprite
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size) // 1
        player.physicsBody?.isDynamic = true // 2
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
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor.green
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        self.PLAYER_BOUNDARY = size.width * 0.2;

        addChild(player)
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addMonster),
                SKAction.wait(forDuration: 1.0)
                ])
            ))
        
        
        //let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        //backgroundMusic.autoplayLooped = true
        //addChild(backgroundMusic)
        //
        // atlas
        //
        setupShelobAnim()
        setupGreyAnim()
        setupExpAnim()
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addMonster() {
        
        // Create sprite
        let mob = Mob.init(newType: MobType.ghost)
        let monster = mob.sprite
        self.addMonsterHp(monster.name!)
        
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
        monster.physicsBody?.isDynamic = true // 2
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
        let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
        
        let actionMoveDone = SKAction.removeFromParent()
        
        let loseAction = SKAction.run() {
            self.monsterEscaped = self.monsterEscaped + 1;
            self.escapedLabel.text = String.localizedStringWithFormat("Escaped: %d", self.monsterEscaped);
            /*
            if(self.monsterEscaped >= self.MONSTER_WIN) {
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                var won = false
                if(self.monstersDestroyed >= self.VICTORY) {
                    won = true
                }
                let gameOverScene = GameOverScene(size: self.size, won: won, message: "Too many monsters escaped")
                self.view?.presentScene(gameOverScene, transition: reveal)
            }
 */
 
        }
        
        // 1
        if (monster.action(forKey: "shelobMoving") != nil) {
            //stop just the moving to a new location, but leave the walking legs movement running
            monster.removeAction(forKey: "shelobMoving")
        }
        
        // 2
        if (monster.action(forKey: "shelobMoving") == nil) {
            //if legs are not moving go ahead and start them
            walkingShelob(monster)
        }
        
        monster.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]),withKey:"shelobMoving")
    }
    
    func walkingShelob(_ shelob:SKSpriteNode) {
        //This is our general runAction method to make shelob walk.
        shelob.run(SKAction.repeatForever(
            SKAction.animate(with: shelobWalkingFrames,
                timePerFrame: 0.1,
                resize: false,
                restore: true)),
                       withKey:"walkingInPlaceShelob")
    }
    
    func firingGrey(_ grey:SKSpriteNode) {
        //This is our general runAction method to make shelob walk.
        grey.run(SKAction.repeat(
            SKAction.animate(with: greyFrames,timePerFrame: 0.1,resize: false,restore: true),
            count: 1))
    }
    
    func explode(_ bomb:SKSpriteNode) {
        //This is our general runAction method to make shelob walk.
        bomb.run(SKAction.repeat(
            SKAction.animate(with: explosionFrames,timePerFrame: 0.3,resize: false,restore: true),
            count: 1))
    }
 
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let player = playerMob.sprite
        
        
        //
        // Defuct ammo
        //
        if(self.ammo > 0) {
            self.ammo = self.ammo - 1;
            
            if (self.ammo <= 0) {
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                var won = false
                if(self.monstersDestroyed >= self.VICTORY) {
                    won = true
                }
                let gameOverScene = GameOverScene(size: self.size, won: won, message: "Out of ammo")
                self.view?.presentScene(gameOverScene, transition: reveal)
            }
            
            ammoLabel.text = String.localizedStringWithFormat("Ammo: %d", self.ammo);
        }
        
        // 1 - Choose one of the touches to work with
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        
        if(touchLocation.x < self.PLAYER_BOUNDARY) { // move
            
            var down = true;
            
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
            let actionMove = SKAction.move(to: CGPoint(x: player.position.x, y: newY), duration: TimeInterval(CGFloat(0.2)))
            
            let moveAction = SKAction.run() {

                
            }
            
            let doneAction = SKAction.run() {
                
                
            }
            
            player.run(SKAction.sequence([actionMove, moveAction, doneAction]))
            
            
        } else {  // shoot
            
            run(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
        
            firingGrey(player)
            
            // Set up initial location of projectile
            let mob = Mob.init(newType: MobType.fireball)
            let projectile = mob.sprite
            projectile.position = player.position
        
            projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
            projectile.physicsBody?.isDynamic = true
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
            let actionMove = SKAction.move(to: realDest, duration: 2.0)
            let actionMoveDone = SKAction.removeFromParent()
            projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
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
            projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, projectile: secondBody.node as! SKSpriteNode)
        } else if ((firstBody.categoryBitMask & PhysicsCategory.Player != 0) &&
            // unexpected nil while unwrapping an optional value here
            (secondBody.categoryBitMask & PhysicsCategory.Monster != 0)) {
            playerDidCollideWithMonster(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
        }
        
    }
    
    func projectileDidCollideWithMonster(_ monster:SKSpriteNode, projectile:SKSpriteNode) {

        self.hitMonster(monster.name!)
        
        projectile.removeFromParent()
        monster.removeFromParent()
        monstersDestroyed = monstersDestroyed + 1
        DataManager.updateScore(self.monstersDestroyed)
        self.updateStage()
        scoreLabel.text = String.localizedStringWithFormat("Score: %d", self.monstersDestroyed);
        
        /*
        if (monstersDestroyed > 20) {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true, message: "You won!")
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
 */
    }
    
    func playerDidCollideWithMonster(_ player:SKSpriteNode, monster:SKSpriteNode) {
        
        
        //let explosion = Mob.init(newType: MobType.Explosion).sprite
        //explosion.position = player.position
        //explosion.zPosition = 5
        //self.explode(explosion)
        
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        var won = false
        if(self.monstersDestroyed >= VICTORY) {
            won = true
        }
        let gameOverScene = GameOverScene(size: self.size, won: won, message:"Monster killed you")
        self.view?.presentScene(gameOverScene, transition: reveal)

    }

    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
    
    fileprivate func showHud() {

        scoreLabel.text = String.localizedStringWithFormat("Score: %d", self.monstersDestroyed);
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = SKColor.black
        scoreLabel.position = CGPoint(x: size.width-100, y: size.height-25)
        addChild(scoreLabel)
        if(DataManager.stats?.highScore == nil) {
            playerNameLabel.text = String.localizedStringWithFormat("High Score: %d",0);
        } else {
            playerNameLabel.text = String.localizedStringWithFormat("High Score: %d", (DataManager.stats?.highScore)!);
        }
        playerNameLabel.fontSize = 20
        playerNameLabel.fontColor = SKColor.black
        playerNameLabel.position = CGPoint(x: size.width/2-20, y: size.height-25)
        addChild(playerNameLabel)
        
        ammoLabel.text = String.localizedStringWithFormat("Ammo: %d", self.ammo);
        ammoLabel.fontSize = 20
        ammoLabel.fontColor = SKColor.black
        ammoLabel.position = CGPoint(x: size.width-100, y: size.height-50)
        addChild(ammoLabel)
        
        escapedLabel.text = String.localizedStringWithFormat("Escaped: %d", self.monsterEscaped);
        escapedLabel.fontSize = 20
        escapedLabel.fontColor = SKColor.black
        escapedLabel.position = CGPoint(x: 100, y: size.height-25)
        addChild(escapedLabel)
        
        stageLabel.text = String.localizedStringWithFormat("Stage: %d", self.stage);
        stageLabel.fontSize = 20
        stageLabel.fontColor = SKColor.black
        stageLabel.position = CGPoint(x: 100, y: size.height-50)
        addChild(stageLabel)
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
        
        if(self.monstersDestroyed > target) {
            //
            // update stage
            //
            self.stage = self.stage + 1
            stageLabel.text = String.localizedStringWithFormat("Stage: %d", self.stage);
            
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
            
            if(self.stage <= stageColourArray.count) {
                
                index  = self.stage - 1;
            } else {
                let remainder = self.stage %  stageColourArray.count
                if(remainder == 0) {
                    index = stageColourArray.count;
                } else {
                    index = remainder - 1;
                }
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
    
    fileprivate func addMonsterHp(_ name:String) {
        
        if monsterHp[name] != nil {
            
        } else {

            monsterHp[name] = 1
        }
    }
    
    fileprivate func setupShelobAnim() {

        var walkFrames = [SKTexture]()

        var spiderTextureName = "shelob1"
        walkFrames.append(atlas.textureNamed(spiderTextureName))
        spiderTextureName = "shelob2"
        walkFrames.append(atlas.textureNamed(spiderTextureName))
        
        shelobWalkingFrames = walkFrames
    }
    
    fileprivate func setupGreyAnim() {
        
        var frames = [SKTexture]()
        
        frames.append(atlas.textureNamed("playerfiring2"))
        frames.append(atlas.textureNamed("playerfiring1"))
        frames.append(atlas.textureNamed("playerfiring2"))
        
        greyFrames = frames
    }
    
    fileprivate func setupExpAnim() {
        
        var frames = [SKTexture]()
        frames.append(atlas.textureNamed("explos1"))
        frames.append(atlas.textureNamed("explos2"))
        explosionFrames = frames
    }
    
    fileprivate func hitMonster(_ name:String) {
        
        if var hp = monsterHp[name] {

            hp = hp - 1
            if(hp<=0) {

                monsterHp.removeValue(forKey: name)
            } else {
 
                monsterHp[name] = hp
            }
        }
    }
}
