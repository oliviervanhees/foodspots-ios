//
//  F4FLocationTableViewController.swift
//  f4f
//
//  Created by Nicky Advokaat on 27/08/15.
//  Copyright (c) 2015 Nubis. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import CoreLocation


class F4FLocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, NSFetchedResultsControllerDelegate {
    
    let locationUpdatesLimit = 10
    
    @IBOutlet
    var tableView: UITableView!
    
    var locationUpdates = [LocationUpdate]()
    
    lazy var locationManager: CLLocationManager! = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        return manager
        }()
    
    lazy var moc: NSManagedObjectContext! = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext!
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()
        
        let fetchRequest = NSFetchRequest(entityName:"LocationUpdate")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do{
            let fetchedResults = try moc.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            locationUpdates = fetchedResults as! [LocationUpdate]
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        
        // Become active after suspended
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshViews", name: UIApplicationWillEnterForegroundNotification, object:nil)

    }
    
    func refreshViews() {
        tableView.reloadData()
    }
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationUpdates.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        
        let locationUpdate:LocationUpdate = locationUpdates[indexPath.row]
                
        cell.textLabel!.text = locationUpdate.toString()
        
        return cell
    }
    
    // MARK: - Location Manager
    
    func locationManager(manager: CLLocationManager,
        didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        setupLocationManager()
    }
    
    func setupLocationManager(){
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways:
            if CLLocationManager.locationServicesEnabled() {
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
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()
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
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
        
        let loc : LocationUpdate = LocationUpdate(context: moc)
        loc.date = NSDate()
        loc.longitude = coord.longitude
        loc.latitude = coord.latitude
        
        var error: NSError?
        do {
            try moc.save()
        } catch let error1 as NSError {
            error = error1
            print("Could not save \(error), \(error?.userInfo)")
        }
        
        // network
        F4FNetworkController.sendLocationUpdate(loc)
        
        if(locationUpdates.count >= locationUpdatesLimit){
            let fetchRequest = NSFetchRequest(entityName: "LocationUpdate")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
            fetchRequest.fetchLimit = 1
            
            do{
                let fetchedResults = try moc.executeFetchRequest(fetchRequest) as? [NSManagedObject]
                let results = fetchedResults as! [LocationUpdate]
                
                let x = results[0]
                
                moc.deleteObject(x)
                var error: NSError?
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    print("Could not save \(error), \(error?.userInfo)")
                }
                
                locationUpdates.removeLast()
            } catch let error as NSError {
                print("Fetch failed: \(error.localizedDescription)")
            }
        }
        
        locationUpdates.insert(loc, atIndex: 0)
        
        // Check whether we are active or in background state
        if UIApplication.sharedApplication().applicationState == .Active {
            tableView.reloadData()
        } else {
            print("background update")
        }
    }
    
    @IBAction func switched(switchState: UISwitch) {
        if switchState.on {
            navigationItem.title = "Tracking In Progress"
            locationManager.startMonitoringSignificantLocationChanges()
        } else {
            navigationItem.title = "Tracking Stopped"
            locationManager.stopMonitoringSignificantLocationChanges()
        }
    }
    
    // Delete all objects
    @IBAction func TrashTapped(sender: UIBarButtonItem) {
        // fetch all
        let fetchRequest = NSFetchRequest(entityName: "LocationUpdate")
        
        do{
            let fetchedResults = try moc.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            let results = fetchedResults as! [LocationUpdate]
            
            for locationUpdate in results {
                moc.deleteObject(locationUpdate)
            }
            
            do {
                try moc.save()
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }
            
            locationUpdates.removeAll(keepCapacity: false)
            tableView.reloadData()

        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        
        
    }
    
}
