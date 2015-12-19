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
import AlamofireImage
import SwiftyJSON

class F4FNetworkController {
    
    private static var API_BASE = "https://foodspots.me/api"
    
    private static func getHeaders() -> [String: String] {
        let token = FBSDKAccessToken.currentAccessToken() != nil ? FBSDKAccessToken.currentAccessToken().tokenString : ""
        
        return [
            "Authorization": "\(token)",
            "Accept": "application/json"
        ];
    }
    
    private static func performRequest(method: Alamofire.Method, uri: String, parameters: [String: AnyObject]?, encoding: ParameterEncoding, callback: (JSON, Int) -> Void) {
        Alamofire.request(method, API_BASE + uri, headers: getHeaders(), parameters: parameters, encoding: encoding).responseJSON { response in
            switch(response.result) {
            case .Success(let data):
                callback(JSON(data), response.response!.statusCode)
                break
            case .Failure(let error):
                if let resp = response.response{
                    switch(resp.statusCode) {
                    case 401:
                        //Unauthorized
                        break
                    case 419:
                        //Token expired
                        break
                    default:
                        //Don't intercept, return the response
                        let json = JSON(data: error.description.dataUsingEncoding(NSUTF8StringEncoding)!)
                        callback(json, response.response!.statusCode)
                        break
                    }
                }else{
                    // No response, possibly no connection
                    callback(nil, 503)
                }
            }
        }
    }
    
    static func performRequest(method: Alamofire.Method, uri: String, parameters: [String: AnyObject]?, callback: (JSON, Int) -> Void) {
        performRequest(method, uri: uri, parameters: parameters, encoding: .URL, callback: callback)
    }
    
    static func performRequestJSONEncoding(method: Alamofire.Method, uri: String, parameters: [String: AnyObject]?, callback: (JSON, Int) -> Void) {
        performRequest(method, uri: uri, parameters: parameters, encoding: .JSON, callback: callback)
    }
    
    static func getImage(uri: String, callback: (UIImage) -> Void) {
        Alamofire.request(.GET, uri).responseImage { response in
            if let image = response.result.value {
                callback(image)
            }else{
            }
        }
    }
    
    class func sendLocationUpdate(locationUpdate: LocationUpdate){
        
        let parameters = [
            "latitude": locationUpdate.latitude,
            "longitude": locationUpdate.longitude
        ]
        
        let headers = [
            "Authorization": "\(FBSDKAccessToken.currentAccessToken().tokenString)",
        ]
        
        Alamofire.request(.POST, "https://foodspots.me/api/location/create", headers: headers, parameters: parameters)
            .responseJSON { response in
                switch (response.result) {
                case .Success(_):
                    break
                case .Failure(let error):
                    print("Network error: \(error)")
                }
        }
    }
}
