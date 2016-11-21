//
//  DataManager.swift
//  GreyWraith
//
//  Created by Alex Vye on 2016-05-30.
//  Copyright © 2016 Alex Vye. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class DataManager {
    
    static var STATS_NAME = "statistics"
    static var stats : Statistics?
    
    static func loadData() -> Statistics {
        
        if(self.stats == nil) {
        
            let ud = UserDefaults.standard
        
            if let data = ud.object(forKey: STATS_NAME) as? Data {
                let unarc = NSKeyedUnarchiver(forReadingWith: data)
                self.stats = (unarc.decodeObject(forKey: "root") as! Statistics)
                
            } else {
                stats = Statistics()
                stats!.highScore = 0
                saveData(self.stats!)
            }
        }
        
        return self.stats!
    }
    
    static func saveData(_ statistics : Statistics) {
        self.stats = statistics
        let ud = UserDefaults.standard
        ud.set(NSKeyedArchiver.archivedData(withRootObject: statistics), forKey: STATS_NAME)
    }
    
    static func updateScore(_ score : Int) {
        if(score > self.stats?.highScore) {
            self.stats?.highScore = score
            self.saveData(self.stats!)
        }
    }
}
