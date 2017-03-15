//
//  Photos+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by osmanjan omar on 3/12/17.
//  Copyright © 2017 osmanjan omar. All rights reserved.
//

import Foundation
import CoreData


public class Photos: NSManagedObject {
    
    //initializing the entity with property
    convenience init(_ photo: NSData, _ context: NSManagedObjectContext ) {
        if let ent = NSEntityDescription.entity(forEntityName: "Photos", in: context) {
            self.init(entity: ent, insertInto: context)
            self.photo = photo
        }
        else {
            fatalError("can not initialize Photos entity")
        }
    }
    
}
