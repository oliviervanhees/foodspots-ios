//
//  F4FFoodSpotsTableViewController.swift
//  f4f
//
//  Created by Nicky Advokaat on 05/12/15.
//  Copyright © 2015 Nubis. All rights reserved.
//

import UIKit

class F4FFoodSpotsTableViewController: UITableViewController, FoodSpotCellLikeTappedDelegate {
    
    var foodSpots:[FoodSpot] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "F4FFoodSpotTableViewCell", bundle: nil), forCellReuseIdentifier: "F4FFoodSpotTableViewCell")
     
        FoodSpot.list() { (result) -> Void in
            self.foodSpots = result
            self.tableView.reloadData()
        }
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
        cell.delegate = self
        
        let foodSpot = foodSpots[indexPath.row]
        cell.labelName.text = foodSpot.name
        let distance = String(format: "%.2f", foodSpot.distance)
        cell.labelDistance.text = "Distance \(distance) km"
        
        foodSpot.image{ image -> Void in
            cell.imageMain!.image = image
            cell.imageMain!.clipsToBounds = true
        }
        
        cell.isLiked = foodSpot.liked
        cell.drawLiked()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func likeTapped(cell: UITableViewCell) {
        if let indexPath = tableView.indexPathForCell(cell){
            let foodSpot = foodSpots[indexPath.row]
            foodSpot.setLiked(!foodSpot.liked){ b in
                if b {
                    foodSpot.liked = !foodSpot.liked
                    cell.setNeedsDisplay()
                    self.tableView.reloadData()
                }
            }

        }
        
    }
    // MARK: - Navigation
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "SegueFoodSpot"){
            let viewController = segue.destinationViewController as! F4FFoodSpotViewController
            let selectedIndex = self.tableView.indexPathForSelectedRow!
            viewController.title = foodSpots[selectedIndex.row]
        }
    }
*/
    
}
