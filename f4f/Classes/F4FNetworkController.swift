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
        
        let parameters = ["latitude": locationUpdate.latitude, "longitude": locationUpdate.longitude]
        //var parameters = ["latitude": 51.639968, "longitude": 4.864036]

        let headers = [
            "Authorization": "\(FBSDKAccessToken.currentAccessToken().tokenString)",
        ]
        
        Alamofire.request(.POST, "http://friends4food.com/api/location/create", headers: headers, parameters: parameters)
        .responseJSON { request, response, result in
            switch (result) {
            case .Success(_):
                print("ok")
            case .Failure(_, let error):
                print(error)
            }
        }
    }
}
