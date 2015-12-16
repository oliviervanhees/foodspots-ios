//
//  F4FMapViewController.swift
//  f4f
//
//  Created by Nicky Advokaat on 05/12/15.
//  Copyright © 2015 Nubis. All rights reserved.
//

import UIKit
import MapKit

class F4FMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var foodSpots:[FoodSpot] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let manager = F4FDataManager.sharedInstance
        foodSpots = manager.foodSpots
        
        initMapView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"foodSpotsChanged:", name: "F4FFoodSpotsChanged", object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Notifications
    
    func foodSpotsChanged(notification: NSNotification) {
        foodSpots = notification.object as! [FoodSpot]
    }
    
    // MARK: - Map

    func initMapView(){        
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.Follow, animated: true)
        
        for foodSpot : FoodSpot in foodSpots {
            if let coordinate = foodSpot.coordinate {
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = foodSpot.name
                annotation.subtitle = foodSpot.foodSpotID
                mapView.addAnnotation(annotation)
            }
        }
    }
    
}
