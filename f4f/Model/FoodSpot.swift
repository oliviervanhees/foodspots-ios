//
//  FoodSpot.swift
//  f4f
//
//  Created by Nicky Advokaat on 15/12/15.
//  Copyright © 2015 Nubis. All rights reserved.
//

import SwiftyJSON
import MapKit

class FoodSpot{
    private static var API_BASE = "/pins"
    
    var foodSpotID: String
    var name: String
    var imageURL: String?
    var location: String?
    var distance: Double
    var coordinate: CLLocationCoordinate2D?
    var liked: Bool = false
    
    var cachedImage: UIImage?
    
    init(_foodSpotID: String, _name: String, _imageURL: String?, _location: String?, _distance: Double, _coordinate: CLLocationCoordinate2D?) {
        foodSpotID = _foodSpotID
        name = _name
        imageURL = _imageURL
        location = _location
        distance = _distance
        coordinate = _coordinate
    }
    
    static func fromJson(obj: JSON) -> FoodSpot {
        let foodSpotID = String(obj["id"].intValue)
        let name = obj["name"].string ?? ""
        let imageURL = obj["external_image_url"].string?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        let location = obj["location"].string
        var distance = obj["distance"].doubleValue ?? 0.0
        distance *= 1.60934 // convert from miles to km
        
        let latitude = obj["latitude"].doubleValue
        let longitude = obj["longitude"].doubleValue
        var coordinate: CLLocationCoordinate2D? = nil
        if latitude != 0 && longitude != 0 {
            coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        }
        
        return FoodSpot(_foodSpotID: foodSpotID, _name: name,_imageURL: imageURL, _location: location, _distance: distance,_coordinate: coordinate)
    }
    
    static func list(cb: ([FoodSpot]) -> Void) {
        let parameters = [
            "latitude": 52.36356159999999,
            "longitude": 4.862994699999945
        ]
        
        F4FNetworkController.performRequest(.GET, uri: API_BASE, parameters: parameters) { (data, code) -> Void in
            let result = data.map{ return FoodSpot.fromJson($1)}
            getLikes(result)
            cb(result)
        }
    }
    
    static func getLikes(foodSpots: [FoodSpot]){
        let pins = foodSpots.map() { return Int($0.foodSpotID)! }
        
        let parameters = [
            "pins": pins
        ]
        
        F4FNetworkController.performRequest(.GET, uri: API_BASE + "/likes", parameters: parameters) { (data, code) -> Void in
            for (_,json):(String, JSON) in data{
                if let id = json["id"].int,let like = json["likes"].bool {
                    let spots = foodSpots.filter(){ return $0.foodSpotID == String(id)}
                    if let spot = spots.first{
                        spot.liked = like
                    }
                }
            }
            // Send out notification
            NSNotificationCenter.defaultCenter().postNotificationName("F4FFoodSpotsLikesChanged", object: nil, userInfo: nil)
        }
    }
    
    func image(cb: (UIImage?) -> Void) {
        if let image = cachedImage{
            cb(image)
        }else{
            if let url = imageURL{
                F4FNetworkController.getImage(url)  { (image) -> Void in
                    self.cachedImage = image
                    cb(image)
                }
            }else{
                cb(nil)
            }
        }
    }
    
    func setLiked(liked: Bool, cb: (Bool) -> Void){
        let parameters = [
            "pin": foodSpotID
        ]
        
        F4FNetworkController.performRequest(.PUT, uri: FoodSpot.API_BASE + "/like", parameters: parameters) { (data, code) -> Void in
            cb(code == 201)
        }
    }
}
