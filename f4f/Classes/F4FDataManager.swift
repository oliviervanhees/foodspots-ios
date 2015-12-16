//
//  F4FDataManager.swift
//  f4f
//
//  Created by Nicky Advokaat on 16/12/15.
//  Copyright © 2015 Nubis. All rights reserved.
//

import Foundation

class F4FDataManager: NSObject {
    
    static let sharedInstance = F4FDataManager()
    
    var foodSpots:[FoodSpot] = []
    
    private override init(){
        super.init()
        
        FoodSpot.list() { (result) -> Void in
            self.foodSpots = result.filter(){ return $0.imageURL != nil }
            NSNotificationCenter.defaultCenter().postNotificationName("F4FFoodSpotsChanged", object: self.foodSpots, userInfo: nil)
        }
        
    }
    
}
