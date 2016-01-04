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
    
    enum FoodSpotListType { case Friends, Nearby }
    
    var foodSpotID: String
    var name: String
    var imageURL: String?
    var location: String?
    var distance: Double
    var coordinate: CLLocationCoordinate2D?
    var liked: Bool = false
    
    var friends: [String] = [] // contains image url's
    
    var nrFriends: Int {
        get{
            return friends.count
        }
    }
    
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
    
    static func list(type: FoodSpotListType, cb: ([FoodSpot]) -> Void) {
        let c = F4FLocationManager.sharedInstance.getLastKnownLocation()
        let lat = Double(c?.latitude ?? 0)
        let lon = Double(c?.longitude ?? 0)
        let parameters = [
            "latitude": lat,
            "longitude": lon
        ]
        
        var uri = API_BASE
        if type == .Friends {
            uri += "/popular"
        }
        
        F4FNetworkController.performRequest(.GET, uri: uri, parameters: parameters) { (data, code) -> Void in
            let result = data.map{ return FoodSpot.fromJson($1)}
            getLikes(result)
            getFriends(result)
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

    static func getFriends(foodSpots: [FoodSpot]){
        let pins = foodSpots.map() { return Int($0.foodSpotID)! }
        
        let parameters = [
            "pins": pins
        ]
        
        F4FNetworkController.performRequest(.GET, uri: API_BASE + "/friends", parameters: parameters) { (data, code) -> Void in
            for (_,json):(String, JSON) in data{
                if let id = json["id"].int, let friends = json["friends"].array {
                    let spots = foodSpots.filter(){ return $0.foodSpotID == String(id)}
                    if let spot = spots.first{
                        for friend in friends {
                            if var imgURL = friend["image_file_name"].string {
                                if (!imgURL.containsString("https")) {
                                    imgURL = imgURL.stringByReplacingOccurrencesOfString("http", withString: "https")
                                }
                                spot.friends.append(imgURL)
                            }
                        }
                    }
                }
            }
            NSNotificationCenter.defaultCenter().postNotificationName("F4FFoodSpotsFriendsChanged", object: nil, userInfo: nil)
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
    
    func imageFriend(nr: Int, cb: (UIImage?) -> Void) {
        assert(0 <= nr && nr < friends.count)
       
        let url = friends[nr]
        F4FNetworkController.getImage(url)  { (image) -> Void in
            cb(image)
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
    
    func openInMaps(){
        if var location = self.location{
            location = location.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            if let targetURL = NSURL(string: "http://maps.apple.com/maps?daddr=\(location)"){
                let isAvailable = UIApplication.sharedApplication().canOpenURL(targetURL)
                if isAvailable {
                    UIApplication.sharedApplication().openURL(targetURL)
                }
            }
        }
    }
}
