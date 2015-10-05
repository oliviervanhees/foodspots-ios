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

class F4FLocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    let locationUpdatesLimit = 10
    
    @IBOutlet
    var tableView: UITableView!
    
    var moc: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName:"LocationUpdate")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetch failed: \(error.userInfo)")
        }
        
        F4FLocationManager.sharedInstance.start()
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let locationUpdate:LocationUpdate = fetchedResultsController.objectAtIndexPath(indexPath) as! LocationUpdate
        
        cell.textLabel?.text = locationUpdate.toString()
        
        return cell
    }
    
    // MARK: - NSFetchedResultsController delegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        case .Update:
            // update cell at indexPath
            break
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    // MARK: - Location Manager
    
    @IBAction func switched(switchState: UISwitch) {
        if switchState.on {
            navigationItem.title = "Tracking In Progress"
            F4FLocationManager.sharedInstance.start()
        } else {
            navigationItem.title = "Tracking Stopped"
            F4FLocationManager.sharedInstance.stop()
        }
    }
    
    // MARK: - Other

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
                print("Could not save: \(error.userInfo)")
            }
            
            tableView.reloadData()
            
        } catch let error as NSError {
            print("Fetch failed: \(error.userInfo)")
        }
    }
    
}
