//
//  MapViewController.swift
//  ExchangeAGram
//
//  Created by Samuel Hooker on 10/12/14.
//  Copyright (c) 2014 Jocus Interactive. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        let location = CLLocationCoordinate2D(latitude: 48.865651652, longitude: 3.375151256)
//        let span = MKCoordinateSpanMake(0.05, 0.05) //span of the map (plus minus, amount of view)
//        let region = MKCoordinateRegionMake(location, span)
//        mapView.setRegion(region, animated: true)
//        
//        let annotation = MKPointAnnotation()
//        annotation.setCoordinate(location)
//        annotation.title = "Somewhere in france"
//        annotation.subtitle = "I believe so"
//        
//        mapView.addAnnotation(annotation)
        
        
        let request = NSFetchRequest(entityName: "FeedItem")
        let appDelegate:AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        let context:NSManagedObjectContext = appDelegate.managedObjectContext!
        var error:NSError?
        
        let itemArray = context.executeFetchRequest(request, error: &error)
        println(error)
        
        
        
        
        if itemArray!.count > 0 {
            for item in itemArray! {
                let location = CLLocationCoordinate2D(latitude: Double(item.latitude), longitude: Double(item.longitude))
                let span = MKCoordinateSpanMake(0.05, 0.05)
                let region = MKCoordinateRegionMake(location, span)
                mapView.setRegion(region, animated: true)
                let annotation = MKPointAnnotation()
                annotation.setCoordinate(location)
                annotation.title = item.caption
                mapView.addAnnotation(annotation)
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
