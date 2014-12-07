//
//  FilterViewController.swift
//  ExchangeAGram
//
//  Created by Samuel Hooker on 4/12/14.
//  Copyright (c) 2014 Jocus Interactive. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var thisFeedItem: FeedItem!
    
    var collectionView: UICollectionView!
    
    let kIntencity = 0.7 //(constant for our filters)
    
    var context:CIContext = CIContext(options: nil)//this will do all the processing
    
    var filters:[CIFilter] = []
    
    let placeholderImage = UIImage(named: "Placeholder")
    
    let tmp = NSTemporaryDirectory() //path of temporary directory that will auto clear.
    
    
    override func viewDidLoad() { //we shall code in the entire UI instead of using storyboard
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSizeMake(150.0, 150.0)
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self //we usually set these by dragging the collection view onto the VC in storyboard
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerClass(filterCell.self, forCellWithReuseIdentifier: "MyCell") //tells what class to use
        
        self.view.addSubview(collectionView)
        
        filters = photoFilters()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //compulsory functions
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filters.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell:filterCell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as filterCell
        
            
        cell.imageView.image = placeholderImage
        //      queue
        let filterQueue:dispatch_queue_t = dispatch_queue_create("filter queue", nil)
        
        dispatch_async(filterQueue, { () -> Void in //filters image on a seperate thread
            
            var filterImage = self.getCachedImage(indexPath.row)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in //when complete, move to main thread and apply image
                cell.imageView.image = filterImage
            })
        })
        
        
        
        
        
        
        return cell
    }
    
    
    //UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) { //item selected
        
        let filterImage = self.filteredImageFromImage(self.thisFeedItem.image, filter: self.filters[indexPath.row]) //renders full image
        
        let imageData = UIImageJPEGRepresentation(filterImage, 1.0) //creates UIImage
        self.thisFeedItem.image = imageData
        // the nice thing about core data is that we can change the instanceof this data at my time (we still must save)
        let thumbnailData = UIImageJPEGRepresentation(filterImage, 0.1)
        self.thisFeedItem.thumbnail = thumbnailData
        
        //save the app delegate to save coredata
        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
        
        self.navigationController?.popToRootViewControllerAnimated(true)//pops VC
    }
    
    
    
    //helper function
    
    
    
    func photoFilters() -> [CIFilter]{ //returns an array of image filters
        
        //basic inbuilt filters
        let blur = CIFilter(name: "CIGaussianBlur")
        let instant = CIFilter(name: "CIPhotoEffectInstant")
        let noir = CIFilter(name: "CIPhotoEffectNoir")
        let transfer = CIFilter(name: "CIPhotoEffectTransfer")
        let unsharpen = CIFilter(name: "CIUnsharpMask")
        let monochrome = CIFilter(name: "CIColorMonochrome")
        
        //more complex filters for awesome hardcores
        
        let colorControls = CIFilter(name: "CIColorControls")
        colorControls.setValue(0.5, forKey: kCIInputSaturationKey) // half saturation
        
        let sepia = CIFilter(name: "CISepiaTone")
        sepia.setValue(kIntencity, forKey: kCIInputIntensityKey)
        
        let colorClamp = CIFilter(name: "CIColorClamp") //changes colors
        colorClamp.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9, w: 0.9), forKey: "inputMaxComponents")//min and max rgba changes acccespted
        colorClamp.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "inputMinComponents")
        let composite = CIFilter(name: "CIHardLightBlendMode")
        composite.setValue(sepia.outputImage, forKey: kCIInputImageKey)
        
        let vignette = CIFilter(name: "CIVignette")
        vignette.setValue(composite.outputImage, forKey: kCIInputImageKey)
        
        vignette.setValue(kIntencity * 2, forKey: kCIInputIntensityKey)
        vignette.setValue(kIntencity * 30, forKey: kCIInputRadiusKey)
        
        return [blur, instant, noir, transfer, unsharpen, monochrome, colorControls, sepia, colorClamp, composite, vignette]
    }
    
    func filteredImageFromImage (imageData: NSData, filter: CIFilter) -> UIImage {
        
        let unfilteredImage = CIImage(data: imageData)
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)
        let filteredImage:CIImage = filter.outputImage
        
        let extent = filteredImage.extent() //makes image small and nice to use (optimised for filter)
        let cgImage:CGImageRef = context.createCGImage(filteredImage, fromRect: extent)
        
        let finalImage = UIImage(CGImage: cgImage)
        
        return finalImage!
    }
    
    
    //////////////////////////      CACHE       /////////////////////////////
    
    
    
    
    
    
    
    func cacheImage(imageNumber:Int){
        let fileName = "\(imageNumber)"
        let uniquePath = tmp.stringByAppendingPathComponent(fileName) //unique file path to hash data to
        
        if !NSFileManager.defaultManager().fileExistsAtPath(fileName){ //if file doesnt exist at file path, generate filter
            
            let data = self.thisFeedItem.thumbnail
            let filter = self.filters[imageNumber]
            let image = filteredImageFromImage(data, filter: filter) //creates a filter
            UIImageJPEGRepresentation(image, 1.0).writeToFile(uniquePath, atomically: true) //saves the Jpeg within a cache
            
        }
    }
        
        
    func getCachedImage(imageNumber:Int) -> UIImage {
        let fileName = "\(imageNumber)"
        let uniquePath = tmp.stringByAppendingPathComponent(fileName) //kinds like retriebving hash slot in hashtable
        var image:UIImage
        
        if NSFileManager.defaultManager().fileExistsAtPath(uniquePath) {
            image = UIImage(contentsOfFile: uniquePath)!
        } else { //if file not found, use previous function to create one wit this hash
            self.cacheImage(imageNumber)
            image = UIImage(contentsOfFile: uniquePath)!
        }
        return image
    
    
        
    }

}