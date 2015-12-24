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
            if(image != nil){
                cell.imageMain!.image = image
                cell.imageMain!.clipsToBounds = true
                cell.imageMain.contentMode = .ScaleAspectFill
            }else{
                cell.imageMain!.image = UIImage(named: "knife_fork.png")
                cell.imageMain.contentMode = .ScaleAspectFit
            }
        }

        let imageViews = [cell.friendImage1!, cell.friendImage2!, cell.friendImage3!]
        for(var i = 0; i < 3; i++){
            let imageView = imageViews[i]
            if(foodSpot.friends.count > i){
                foodSpot.imageFriend(i){ image -> Void in
                    imageView.image = image?.af_imageWithRoundedCornerRadius(2)
                    imageView.clipsToBounds = true
                }
            }else{
                imageView.image = nil
            }
        }
        
        cell.labelFriends.text = "Favorite FoodSpot of: (\(foodSpot.nrFriends))"
        
        cell.isLiked = foodSpot.liked
        cell.drawLiked()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    // MARK: - FoodSpot button delegate
    
    func likeTapped(cell: F4FFoodSpotTableViewCell) {
        if let indexPath = tableView.indexPathForCell(cell){
            let foodSpot = foodSpots[indexPath.row]
            
            if(foodSpot.liked){

            }else{
                foodSpot.setLiked(!foodSpot.liked){ success in
                    if success {
                        foodSpot.liked = !foodSpot.liked
                       
                    }
                    cell.isLiked = foodSpot.liked
                    cell.drawLiked()
                }
            }
        }
    }
    
    func routeTapped(cell: F4FFoodSpotTableViewCell) {
        if let indexPath = tableView.indexPathForCell(cell){
            let foodSpot = foodSpots[indexPath.row]
            foodSpot.openInMaps()
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
