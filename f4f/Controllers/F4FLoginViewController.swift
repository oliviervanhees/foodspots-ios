//
//  ViewController.swift
//  f4f
//
//  Created by Nicky Advokaat on 26/08/15.
//  Copyright (c) 2015 Nubis. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class F4FLoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var facebookLoginView: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Facebook Login button
        facebookLoginView.readPermissions = ["public_profile", "email", "user_friends"]
        facebookLoginView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Login screen")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }

    // MARK - Facebook Button
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
    {
        if error == nil {
            // Logged in successfuly
            
            F4FDataManager.sharedInstance.updateFoodSpots()
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc =  storyboard.instantiateInitialViewController() as UIViewController!
            appDelegate.window?.rootViewController = vc;
            appDelegate.window?.makeKeyAndVisible()
        } else {
            print(error.localizedDescription)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!)
    {
    }
}
