//
//  F4FFoodSpotsTableViewController.swift
//  f4f
//
//  Created by Nicky Advokaat on 05/12/15.
//  Copyright © 2015 Nubis. All rights reserved.
//

import UIKit


class F4FFoodSpotsTableViewController: UITableViewController, FoodSpotCellLikeTappedDelegate {
    
    @IBInspectable var isFriendsView: Bool = false

    var foodSpots:[FoodSpot] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "F4FFoodSpotTableViewCell", bundle: nil), forCellReuseIdentifier: "F4FFoodSpotTableViewCell")
        
        tableView.separatorStyle = .None
        tableView.backgroundColor = F4FColors.backgroundColorLight
        
        let manager = F4FDataManager.sharedInstance
        foodSpots = isFriendsView ? manager.foodSpotsFriends : manager.foodSpotsNearby
        
        // Subscribe to notification
        let notification = isFriendsView ? "F4FFoodSpotsFriendsListChanged" : "F4FFoodSpotsNearbyListChanged"
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(F4FFoodSpotsTableViewController.foodSpotsChanged(_:)), name: notification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(F4FFoodSpotsTableViewController.likesChanged(_:)), name: "F4FFoodSpotsLikesChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(F4FFoodSpotsTableViewController.friendsChanged(_:)), name: "F4FFoodSpotsFriendsChanged", object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Main screen")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    // MARK: - Notifications
    
    func foodSpotsChanged(notification: NSNotification) {
        foodSpots = notification.object as! [FoodSpot]
        tableView.reloadData()
    }
    
    func likesChanged(notification: NSNotification) {
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
        
        cell.imageMain!.image = UIImage(named: "knife_fork.png")
        cell.imageMain.contentMode = .ScaleAspectFit
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
        for i in 0 ..< 3 {
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
                // GA
                let tracker = GAI.sharedInstance().defaultTracker
                tracker.send(GAIDictionaryBuilder.createEventWithCategory("FoodSpots", action: "Liked", label: foodSpot.name, value: nil).build() as [NSObject : AnyObject])

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
}
