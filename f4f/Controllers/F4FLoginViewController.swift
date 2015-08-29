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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup Facebook Login button
        var loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        loginButton.center = self.view.center
        loginButton.delegate = self
        self.view.addSubview(loginButton)
    }

    // MARK - Facebook Button
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
    {
        if error == nil {
            // Logged in successfuly
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            var vc =  storyboard.instantiateInitialViewController() as! UIViewController
            appDelegate.window?.rootViewController = vc;
            appDelegate.window?.makeKeyAndVisible()
        } else {
            println(error.localizedDescription)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!)
    {
    }
    
}

