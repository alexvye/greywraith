//
//  Statistics.swift
//  GreyWraith
//
//  Created by Alex Vye on 2016-05-30.
//  Copyright © 2016 Alex Vye. All rights reserved.
//

import Foundation

class Statistics : NSObject, NSCoding  {

    var highScore: Int?
    
    override init() {}
    
    required init(coder aDecoder: NSCoder) {
        if let highScore = aDecoder.decodeObject(forKey: "highScore") as? Int {
            self.highScore = highScore
        }
    }
    
    func encode(with aCoder: NSCoder) {
        if let highScore = self.highScore {
            aCoder.encode(highScore, forKey: "highScore")
        }
    }
}
