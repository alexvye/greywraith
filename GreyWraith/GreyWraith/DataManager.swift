//
//  DataManager.swift
//  GreyWraith
//
//  Created by Alex Vye on 2016-05-30.
//  Copyright © 2016 Alex Vye. All rights reserved.
//

import Foundation

class DataManager {
    
    static var STATS_NAME = "statistics"
    static var stats : Statistics?
    
    static func loadData() -> Statistics {
        
        if(self.stats == nil) {
        
            let ud = NSUserDefaults.standardUserDefaults()
        
            if let data = ud.objectForKey(STATS_NAME) as? NSData {
                let unarc = NSKeyedUnarchiver(forReadingWithData: data)
                self.stats = (unarc.decodeObjectForKey("root") as! Statistics)
                
            } else {
                stats = Statistics()
                stats!.highScore = 0
                saveData(self.stats!)
            }
        }
        
        return self.stats!
    }
    
    static func saveData(statistics : Statistics) {
        self.stats = statistics
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(NSKeyedArchiver.archivedDataWithRootObject(statistics), forKey: STATS_NAME)
    }
    
    static func updateScore(score : Int) {
        if(score > self.stats?.highScore) {
            self.stats?.highScore = score
            self.saveData(self.stats!)
        }
    }
}
