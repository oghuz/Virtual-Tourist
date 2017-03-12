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
    @NSManaged public func addToToPhotos(_ value: Photos)

    @objc(removeToPhotosObject:)
    @NSManaged public func removeFromToPhotos(_ value: Photos)

    @objc(addToPhotos:)
    @NSManaged public func addToToPhotos(_ values: NSSet)

    @objc(removeToPhotos:)
    @NSManaged public func removeFromToPhotos(_ values: NSSet)

}
