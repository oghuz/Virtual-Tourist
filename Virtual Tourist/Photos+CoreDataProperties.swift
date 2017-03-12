//
//  Photos+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by osmanjan omar on 3/12/17.
//  Copyright © 2017 osmanjan omar. All rights reserved.
//

import Foundation
import CoreData


extension Photos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photos> {
        return NSFetchRequest<Photos>(entityName: "Photos");
    }

    @NSManaged public var photo: NSData?
    @NSManaged public var toCoordination: Coordination?

}
