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
    case Player
    case Ghost
    case Fireball
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

func getSpriteForType(mobType:MobType) -> SKSpriteNode {
    
    var newSprite:SKSpriteNode
    
    switch(mobType) {
        case MobType.Player:
            newSprite = SKSpriteNode(imageNamed: "player1")
        case MobType.Ghost:
            newSprite = SKSpriteNode(imageNamed: "shelob1")
        case MobType.Fireball:
            newSprite = SKSpriteNode(imageNamed: "fireball")
    }
    
    newSprite.name = NSUUID().UUIDString
    
    return newSprite
}

func getHitPointsForType(mobType:MobType) -> Int {
    
    var hp:Int
    
    switch(mobType) {
        case MobType.Player:
            hp = 2;
        case MobType.Ghost:
            hp = 2;
        default:
            hp = 1;
    }
    
    return hp
}

func generateNameForType(mobType:MobType) -> String {
    
    var name:String
    
    switch(mobType) {
        case MobType.Ghost:
            name = NSUUID().UUIDString;
        default:
            name = NSUUID().UUIDString;
    }
    
    return name
}
