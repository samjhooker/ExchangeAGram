//
//  FeedItem.swift
//  ExchangeAGram
//
//  Created by Samuel Hooker on 5/12/14.
//  Copyright (c) 2014 Jocus Interactive. All rights reserved.
//

import Foundation
import CoreData


@objc (FeedItem) //allows obj c code
class FeedItem: NSManagedObject {

    @NSManaged var caption: String
    @NSManaged var image: NSData
    @NSManaged var thumbnail: NSData // for compressed photographs

}