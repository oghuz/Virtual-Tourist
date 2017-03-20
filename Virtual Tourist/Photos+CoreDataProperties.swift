//
//  Photos+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by osmanjan omar on 3/20/17.
//  Copyright © 2017 osmanjan omar. All rights reserved.
//

import Foundation
import CoreData


extension Photos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photos> {
        return NSFetchRequest<Photos>(entityName: "Photos");
    }

    @NSManaged public var pagenumber: Int16
    @NSManaged public var photo: NSData?
    @NSManaged public var url: String?
    @NSManaged public var toCoordination: Coordination?

}
