//
//  F4FMapViewController.swift
//  f4f
//
//  Created by Nicky Advokaat on 05/12/15.
//  Copyright © 2015 Nubis. All rights reserved.
//

import UIKit
import MapKit

class F4FMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var foodSpots:[FoodSpot] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let manager = F4FDataManager.sharedInstance
        foodSpots = manager.foodSpotsNearby
        
        mapView.delegate = self
        
        initMapView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(F4FMapViewController.foodSpotsChanged(_:)), name: "F4FFoodSpotsChanged", object: nil)
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
            if let _ = foodSpot.coordinate {
                let annotation = MapPin(foodSpot: foodSpot)
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Return nil for the user location to show the blue dot
        if(annotation.isKindOfClass(MKUserLocation.classForCoder())){
            return nil
        }
        
        // Else show our custom pin
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier("test")
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "test")
            view?.canShowCallout = true
            
            let routeButton = UIButton(type: UIButtonType.Custom) as UIButton
            routeButton.frame.size.width = 50
            routeButton.frame.size.height = 55
            routeButton.backgroundColor = F4FColors.blueColor
            routeButton.setImage(UIImage(named: "Car")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
            routeButton.tintColor = UIColor.whiteColor()
            
            view?.leftCalloutAccessoryView = routeButton
        } else {
            view?.annotation = annotation
        }
        return view
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.leftCalloutAccessoryView {
            let selectedAnnotation = view.annotation as? MapPin
            let foodSpot = selectedAnnotation?.foodSpot
            foodSpot!.openInMaps()

        }
    }

    class MapPin : NSObject, MKAnnotation {
        var coordinate: CLLocationCoordinate2D
        var title: String?
        var subtitle: String?
        var foodSpot: FoodSpot
        
        init(foodSpot: FoodSpot) {
            self.coordinate = foodSpot.coordinate!
            self.title = foodSpot.name
            self.subtitle = nil
            self.foodSpot = foodSpot
        }
    }
}
