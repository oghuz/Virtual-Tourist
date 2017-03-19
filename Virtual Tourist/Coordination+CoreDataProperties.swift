//
//  Coordination+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by osmanjan omar on 3/12/17.
//  Copyright © 2017 osmanjan omar. All rights reserved.
//

import Foundation
import CoreData


extension Coordination {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Coordination> {
        return NSFetchRequest<Coordination>(entityName: "Coordination");
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var toPhotos: NSSet?

}

// MARK: Generated accessors for toPhotos
extension Coordination {

    @objc(addToPhotosObject:)
    @NSManaged public func addToPhotos(_ value: Photos)

    @objc(removeToPhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: Photos)

    @objc(addToPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removeToPhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)

}
