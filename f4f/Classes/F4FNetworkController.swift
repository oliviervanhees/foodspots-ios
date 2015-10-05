//
//  F4FNetworkController.swift
//  f4f
//
//  Created by Nicky Advokaat on 29/08/15.
//  Copyright (c) 2015 Nubis. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit
import Alamofire
import SwiftyJSON

class F4FNetworkController {
    
    class func sendLocationUpdate(locationUpdate: LocationUpdate){
        
        let parameters = [
            "latitude": locationUpdate.latitude,
            "longitude": locationUpdate.longitude
        ]
        
        let headers = [
            "Authorization": "\(FBSDKAccessToken.currentAccessToken().tokenString)",
        ]
        
        Alamofire.request(.POST, "http://friends4food.com/api/location/create", headers: headers, parameters: parameters)
            .responseJSON { request, response, result in
                switch (result) {
                case .Success(_):
                    break
                case .Failure(_, let error):
                    print("Network error: \(error)")
                }
        }
    }
}
