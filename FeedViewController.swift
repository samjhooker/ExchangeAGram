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

class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate { //last 2 needed for camera

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        //COREDATA
        let managedObjectContext = (UIApplication.sharedApplication().deleagte as AppDelegate).managedObjectContext // get managed object context from app delegate
        let entityDescription = NSEntityDescription.entityForName("FeedItem", inManagedObjectContext: managedObjectContext!) // more or less, creating an instance of FeedItem
        let feedItem = FeedItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
        
        feedItem.image = imageData
        feedItem.caption = "test caption"
        
        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
        
        self.dismissViewControllerAnimated(true, completion: nil)//dismisses image picker controller
    
    }
    
    
    
    
    //UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {  //compulsory functions
        return  1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
}
