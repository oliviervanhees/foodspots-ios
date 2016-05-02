//
//  F4FSettingsViewController.swift
//  f4f
//
//  Created by Nicky Advokaat on 28/08/15.
//  Copyright (c) 2015 Nubis. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class F4FSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Settings screen")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }

    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        cell.textLabel!.text = "Log out"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Stop monitoring location
        F4FLocationManager.sharedInstance.stop()
        
        // Log out Facebook
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        // Show the LoginViewController
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.showRootViewController()
    }
    
}
