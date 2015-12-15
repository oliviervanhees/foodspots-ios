//
//  F4FLocationManager.swift
//  f4f
//
//  Created by Nicky Advokaat on 30/09/15.
//  Copyright © 2015 Nubis. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import CoreData

class F4FLocationManager: NSObject, CLLocationManagerDelegate{
    
    static let sharedInstance = F4FLocationManager()
    
    let maxNumberLocationUpdates = 10
    
    var moc: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    var locationManager: CLLocationManager! =  CLLocationManager()
    
    private override init(){
        super.init()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        //setupLocationManager(false);
    }
    
    func start(){
        setupLocationManager(true);
    }
    
    func stop(){
        if(CLLocationManager.authorizationStatus() == .AuthorizedAlways){
            locationManager.stopMonitoringSignificantLocationChanges()
        }
    }
    
    func setupLocationManager(start: Bool){
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways:
            if CLLocationManager.locationServicesEnabled() && start {
                locationManager.startMonitoringSignificantLocationChanges()
            }
        case .NotDetermined:
            locationManager.requestAlwaysAuthorization()
        case .AuthorizedWhenInUse, .Restricted, .Denied:
            let alertController = UIAlertController(
                title: "Background Location Access Disabled",
                message: "In order to update restaurants, please open this app's settings and set location access to 'Always'.",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)
            
            alertController.show()
        }
    }
    
    func locationManager(manager: CLLocationManager,
        didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        print("changed")
        setupLocationManager(true)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopMonitoringSignificantLocationChanges()
        print("LocationManager failed: \(error)", terminator: "")
        
        let alertController = UIAlertController(
            title: "Location Unavailable",
            message: "Location could not be determined",
            preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let retryAction = UIAlertAction(title: "Retry", style: .Default) { (action) in
            self.locationManager.startMonitoringSignificantLocationChanges()
        }
        alertController.addAction(retryAction)
        
        alertController.show()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
        
        let loc : LocationUpdate = LocationUpdate(context: moc)
        loc.date = NSDate()
        loc.longitude = coord.longitude
        loc.latitude = coord.latitude
        
        do {
            try moc.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        // network
        F4FNetworkController.sendLocationUpdate(loc)
        
        
        let fetchRequest = NSFetchRequest(entityName: "LocationUpdate")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do{
            let fetchedResults = try moc.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            let results = fetchedResults as! [LocationUpdate]
           
            for var i = 0; i < results.count - maxNumberLocationUpdates; i++ {
                let objectToDelete = results[i]
                moc.deleteObject(objectToDelete)
            }
            
            do {
                try moc.save()
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }
            
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
    }
}

// This extensions enables showing alerts without access to a viewcontroller
extension UIAlertController {
    
    func show() {
        present(animated: true, completion: nil)
    }
    
    func present(animated animated: Bool, completion: (() -> Void)?) {
        if let rootVC = UIApplication.sharedApplication().keyWindow?.rootViewController {
            presentFromController(rootVC, animated: animated, completion: completion)
        }
    }
    
    private func presentFromController(controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if  let navVC = controller as? UINavigationController,
            let visibleVC = navVC.visibleViewController {
                presentFromController(visibleVC, animated: animated, completion: completion)
        } else
            if  let tabVC = controller as? UITabBarController,
                let selectedVC = tabVC.selectedViewController {
                    presentFromController(selectedVC, animated: animated, completion: completion)
            } else {
                controller.presentViewController(self, animated: animated, completion: completion)
        }
    }
}
