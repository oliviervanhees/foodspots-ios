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
        
        tableView.separatorStyle = .None
        tableView.backgroundColor = F4FColors.backgroundColorLight
        
        let manager = F4FDataManager.sharedInstance
        foodSpots = manager.foodSpots
        
        // Subscribe to notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"likesChanged:", name: "F4FFoodSpotsLikesChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"foodSpotsChanged:", name: "F4FFoodSpotsChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"friendsChanged:", name: "F4FFoodSpotsFriendsChanged", object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Notifications
    
    func likesChanged(notification: NSNotification) {
        tableView.reloadData()
    }
    
    func foodSpotsChanged(notification: NSNotification) {
        foodSpots = notification.object as! [FoodSpot]
        tableView.reloadData()
    }
    
    func friendsChanged(notification: NSNotification) {
        tableView.reloadData()
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
        
        if(foodSpot.friends.count > 0){
            foodSpot.imageFriend(0){ image -> Void in
                cell.friendImage1!.image = image
                cell.friendImage1!.clipsToBounds = true
            }
        }else{
            cell.friendImage1.image = nil
        }
        if(foodSpot.friends.count > 1){
            foodSpot.imageFriend(1){ image -> Void in
                cell.friendImage2!.image = image
                cell.friendImage2!.clipsToBounds = true
            }
        }else{
            cell.friendImage3.image = nil
        }
        if(foodSpot.friends.count > 2){
            foodSpot.imageFriend(2){ image -> Void in
                cell.friendImage3!.image = image
                cell.friendImage3!.clipsToBounds = true
            }
        }else{
            cell.friendImage3.image = nil
        }
        
        cell.labelFriends.text = "Favorite FoodSpot of: (\(foodSpot.nrFriends))"
        
        cell.isLiked = foodSpot.liked
        cell.drawLiked()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func likeTapped(cell: F4FFoodSpotTableViewCell) {
        if let indexPath = tableView.indexPathForCell(cell){
            let foodSpot = foodSpots[indexPath.row]
            
            if(foodSpot.liked){
                if var location = foodSpot.location{
                    location = location.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                    if let targetURL = NSURL(string: "http://maps.apple.com/maps?daddr=\(location)"){
                        let isAvailable = UIApplication.sharedApplication().canOpenURL(targetURL)
                        if isAvailable {
                            UIApplication.sharedApplication().openURL(targetURL)
                        }
                    }
                }
            }else{
                foodSpot.setLiked(!foodSpot.liked){ success in
                    if success {
                        foodSpot.liked = !foodSpot.liked
                        cell.isLiked = foodSpot.liked
                        cell.drawLiked()
                        cell.setNeedsDisplay()
                        self.tableView.reloadData()
                    }
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
