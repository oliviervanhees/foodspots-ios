//
//  F4FFoodSpotsTableViewController.swift
//  f4f
//
//  Created by Nicky Advokaat on 05/12/15.
//  Copyright © 2015 Nubis. All rights reserved.
//

import UIKit

class F4FFoodSpotsTableViewController: UITableViewController {
    
    let foodSpots = ["Cafe Proost","Restaurant X"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "F4FFoodSpotTableViewCell", bundle: nil), forCellReuseIdentifier: "F4FFoodSpotTableViewCell")
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodSpots.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("F4FFoodSpotTableViewCell", forIndexPath: indexPath) as! F4FFoodSpotTableViewCell
        
        cell.textLabel?.text = foodSpots[indexPath.row]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //performSegueWithIdentifier("SegueFoodSpot", sender: self)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "SegueFoodSpot"){
            let viewController = segue.destinationViewController as! F4FFoodSpotViewController
            let selectedIndex = self.tableView.indexPathForSelectedRow!
            viewController.title = foodSpots[selectedIndex.row]
        }
    }
    
}
