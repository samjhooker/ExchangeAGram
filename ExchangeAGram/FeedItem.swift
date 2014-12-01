//
//  FeedItem.swift
//  ExchangeAGram
//
//  Created by Samuel Hooker on 2/12/14.
//  Copyright (c) 2014 Jocus Interactive. All rights reserved.
//

import Foundation
import CoreData


@objc (FeedItem) //allows the class to work with obj c
class FeedItem: NSManagedObject {

    @NSManaged var caption: String
    @NSManaged var image: NSData

}
