//
//  Mob.swift
//  GreyWraith
//
//  Created by Alex Vye on 2016-05-11.
//  Copyright © 2016 Alex Vye. All rights reserved.
//

import Foundation
import SpriteKit

enum MobType {
    case player
    case ghost
    case fireball
    case explosion
}

class Mob {
    
    var sprite: SKSpriteNode
    var hitPoints: Int
    var type: MobType

    init(newType:MobType) {
        self.sprite = getSpriteForType(newType)
        self.type = newType
        self.hitPoints = getHitPointsForType(newType)
    }
}

func getSpriteForType(_ mobType:MobType) -> SKSpriteNode {
    
    var newSprite:SKSpriteNode
    
    switch(mobType) {
        case MobType.player:
            newSprite = SKSpriteNode(imageNamed: "playerfiring2")
        case MobType.ghost:
            newSprite = SKSpriteNode(imageNamed: "shelob1")
        case MobType.fireball:
            newSprite = SKSpriteNode(imageNamed: "fireball")
    case MobType.explosion:
            newSprite = SKSpriteNode(imageNamed: "explos1")
    }
    
    newSprite.name = UUID().uuidString
    
    return newSprite
}

func getHitPointsForType(_ mobType:MobType) -> Int {
    
    var hp:Int
    
    switch(mobType) {
        case MobType.player:
            hp = 2;
        case MobType.ghost:
            hp = 2;
        default:
            hp = 1;
    }
    
    return hp
}

func generateNameForType(_ mobType:MobType) -> String {
    
    var name:String
    
    switch(mobType) {
        case MobType.ghost:
            name = UUID().uuidString;
        default:
            name = UUID().uuidString;
    }
    
    return name
}
