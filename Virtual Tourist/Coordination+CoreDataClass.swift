//
//  Coordination+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by osmanjan omar on 3/20/17.
//  Copyright © 2017 osmanjan omar. All rights reserved.
//

import Foundation
import CoreData


public class Coordination: NSManagedObject {

    //initializing the entity with properties
    convenience init(_ latitude: Double, _ longitude: Double, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Coordination", in: context) {
            self.init(entity: ent, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
        }
        else {
            fatalError("can not initialize coordination")
        }
    }

}
