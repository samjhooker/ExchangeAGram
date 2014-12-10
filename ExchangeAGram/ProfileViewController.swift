//
//  ProfileViewController.swift
//  ExchangeAGram
//
//  Created by Samuel Hooker on 5/12/14.
//  Copyright (c) 2014 Jocus Interactive. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, FBLoginViewDelegate { //have to add FBloginViewDelegate for FB functions to work

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var fbLoginView: FBLoginView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.fbLoginView.delegate = self // when the callback messages are called, they are retuned to the profile VC instance.
        self.fbLoginView.readPermissions = ["public_profile", "publish_actions"]//shows user what info we are stealing
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func mapViewButtonTapped(sender: UIButton) {
        performSegueWithIdentifier("mapSegue", sender: nil)
    }
    
    
    //FACEBOOK functions //these are the 4 login facebook function from the deleagte class
    
    func loginViewShowingLoggedInUser(loginView: FBLoginView!) { //while user fully logged in
        profileImageView.hidden = false
        nameLabel.hidden = false
    }
    
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!) {//info got whilst logging in
        
        println(user)
        
        nameLabel.text = user.name
        
        //have to acceess image through URL
        let userImageURL = "https://graph.facebook.com/\(user.objectID)/picture?type=small"
        let url = NSURL(string: userImageURL)
        let imageData = NSData(contentsOfURL: url!)
        let image = UIImage(data: imageData!)
        
        profileImageView.image = image
    
        
        
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) { //  logged out
        profileImageView.hidden = true
        nameLabel.hidden = true
    }
    func loginView(loginView: FBLoginView!, handleError error: NSError!) { //error while login
        println("error: \(error.localizedDescription)")
    }
}
