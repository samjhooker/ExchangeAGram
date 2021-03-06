//
//  FeedViewController.swift
//  ExchangeAGram
//
//  Created by Samuel Hooker on 2/12/14.
//  Copyright (c) 2014 Jocus Interactive. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData
import MapKit

class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
                                            //for UICollectionView                                    // for image picker (ie, camera or gallery)                   // for location services
    @IBOutlet weak var collectionView: UICollectionView!
    
    var feedArray:[AnyObject] = []
    
    var locationManager: CLLocationManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //best accuracy possible
        
        locationManager.requestAlwaysAuthorization() // gives popup to ask for location, must be setup in info.plist
        
        locationManager.distanceFilter = 100.0 //distance changed before location update
        locationManager.startUpdatingLocation()
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        // we need to request all the instance of FeedItem
        let request = NSFetchRequest(entityName: "FeedItem")
        //access instance app delegate
        let appDelegate:AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        //access context (optional porperty of the app delegate)
        let context:NSManagedObjectContext = appDelegate.managedObjectContext!
        feedArray = context.executeFetchRequest(request, error: nil)!  //doesnt know what type it is returning therefore must use AnyObject when defining array.
        //all feed item instances will be put into the feed array.
        collectionView.reloadData()
        
        
    }
    
    @IBAction func profileTapped(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("profileSegue", sender: nil)
    }

    /*
      ___ __ _ _ __ ___   ___ _ __ __ _
     / __/ _` | '_ ` _ \ / _ \ '__/ _` |
    | (_| (_| | | | | | |  __/ | | (_| |
     \___\__,_|_| |_| |_|\___|_|  \__,_|
    
    */
    
    
    
    @IBAction func snapBarButtonItemTapped(sender: UIBarButtonItem) { //camera button pressed
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){ //checks if camera is availiable
            var cameraController = UIImagePickerController() //creates instance of media object
            cameraController.delegate = self
            cameraController.sourceType = UIImagePickerControllerSourceType.Camera //selects the media object as a camera
            
            let mediaTypes:[AnyObject] = [kUTTypeImage] // abstract type, specifing image data
            cameraController.mediaTypes = mediaTypes // media type is an image
            
            cameraController.allowsEditing  = false
            
            self.presentViewController(cameraController, animated: true, completion: nil)// present the camera (actually opens it)
            
        }
        else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
            var photoLibraryController = UIImagePickerController()
            photoLibraryController.delegate = self
            photoLibraryController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            let mediaTypes:[AnyObject] = [kUTTypeImage]
            photoLibraryController.mediaTypes = mediaTypes
            photoLibraryController.allowsEditing = false
            self.presentViewController(photoLibraryController, animated: true, completion: nil)
        }
        else{
            var alertView = UIAlertController(title: "Alert", message: "your device dowes not support camera or photo library", preferredStyle: UIAlertControllerStyle.Alert)
            alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertView, animated: true, completion: nil)
        }
    }
    
    ///UIImagePickerController Delagate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) { //finish picking image
        
        let image = info[UIImagePickerControllerOriginalImage] as UIImage // this gets the image as it passed in through the 'info' argument
        let imageData = UIImageJPEGRepresentation(image, 1.0)//converts the UIImage into JPG NSData instance (which is required for our FeedItem item)
        let thumbnailData = UIImageJPEGRepresentation(image, 0.01) //image with 0.1 compression quality (lower is faster)
        
        //COREDATA
        let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext // get managed object context from app delegate
        let entityDescription = NSEntityDescription.entityForName("FeedItem", inManagedObjectContext: managedObjectContext!) // more or less, creating an instance of FeedItem
        let feedItem = FeedItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
        
        feedItem.image = imageData
        feedItem.caption = "test caption"
        feedItem.thumbnail = thumbnailData
        
        if let location = locationManager.location? {
            feedItem.latitude = locationManager.location.coordinate.latitude
            feedItem.longitude = locationManager.location.coordinate.longitude
        }
        else {
            println("No location available")
        }
        
        
        let UUID = NSUUID().UUIDString //apple with generate a uniqye string ID automatically
        feedItem.uniqueID = UUID //gets set as the ID for the item
        //println(feedItem.uniqueID)
        
        
        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
        
        
        feedArray.append(feedItem)
        
        self.dismissViewControllerAnimated(true, completion: nil)//dismisses image picker controller
        
        self.collectionView.reloadData()
    }
    
    
    
    
    //UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {  //compulsory functions
        return  1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedArray.count //number of all cells
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell { //creates each instnace of the a cell.
        
        // creates a reuasbale cell (instance of FeedCell)
        var cell:FeedCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as FeedCell
        
        let thisItem = feedArray[indexPath.row] as FeedItem // finds the data needed
        
        cell.imageView.image = UIImage(data: thisItem.image)//have to convert back from data to image file
        cell.captionLabel.text = thisItem.caption
        
        return cell
        
        
    }
    
    //UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) { //cell tapped on
        let thisItem = feedArray[indexPath.row] as FeedItem //this item is the item tapped on
        
        var filterVc = FilterViewController() //creates an instance of the filter View Controller
        filterVc.thisFeedItem = thisItem
        
        self.navigationController?.pushViewController(filterVc, animated: false) //pushes view controller
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////       CLLocationManagerDelegate   ////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        println("locations = \(locations)")
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        if error.code != CLError.LocationUnknown.rawValue{
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    
    
    
    
}
