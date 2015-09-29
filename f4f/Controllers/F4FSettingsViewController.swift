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
        print("tapped")
        
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.showRootViewController()

    }

}
