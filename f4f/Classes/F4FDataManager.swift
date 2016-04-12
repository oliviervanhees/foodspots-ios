//
//  F4FDataManager.swift
//  f4f
//
//  Created by Nicky Advokaat on 16/12/15.
//  Copyright © 2015 Nubis. All rights reserved.
//

import Foundation
import MapKit
import FBSDKCoreKit

class F4FDataManager: NSObject {
    
    static let sharedInstance = F4FDataManager()
    
    var foodSpotsNearby:[FoodSpot] = []
    var foodSpotsFriends:[FoodSpot] = []
    
    private override init(){
        super.init()
    
        if(FBSDKAccessToken.currentAccessToken() != nil){
            updateFoodSpots()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(F4FDataManager.locationUpdate(_:)), name: "F4FLocationUpdate", object: nil)
    }
    
    func updateFoodSpots(){
        FoodSpot.list(.Nearby) { (result) -> Void in
            self.foodSpotsNearby = result
            NSNotificationCenter.defaultCenter().postNotificationName("F4FFoodSpotsNearbyListChanged", object: self.foodSpotsNearby, userInfo: nil)
        }
        
        FoodSpot.list(.Friends) { (result) -> Void in
            self.foodSpotsFriends = result
            NSNotificationCenter.defaultCenter().postNotificationName("F4FFoodSpotsFriendsListChanged", object: self.foodSpotsFriends, userInfo: nil)
        }
    }
    
    // MARK: - Notifications
    
    func locationUpdate(notification: NSNotification) {
        if let _ = notification.userInfo!["latitude"]?.doubleValue, let _ = notification.userInfo!["longitude"]?.doubleValue{
            updateFoodSpots()
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
