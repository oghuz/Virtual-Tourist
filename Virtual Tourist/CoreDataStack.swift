//
//  CoreDataStack.swift
//  Virtual Tourist
//
//  Created by osmanjan omar on 3/12/17.
//  Copyright © 2017 osmanjan omar. All rights reserved.
//

import Foundation
import CoreData

struct CoreDataStack {
    
    //#MARK: -properties
    fileprivate let managedObjectModel: NSManagedObjectModel
    let coordinator: NSPersistentStoreCoordinator
    fileprivate let modelURL: URL
    fileprivate let dataBaseURL: URL
    fileprivate let persistingContext: NSManagedObjectContext
    fileprivate let backgroundContext: NSManagedObjectContext
    let context: NSManagedObjectContext
    
    //#MARK: initializing
    
    init?(modelName name: String) {
        guard let modelURL = Bundle.main.url(forResource: name, withExtension: "momd") else {
            print("Error getting managedobjectmodel URl")
            return nil
        }
        
        self.modelURL = modelURL
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            print("unable to create managed object model with url: \(modelURL)")
            return nil
        }
        
        self.managedObjectModel = managedObjectModel
        
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        //chaining private and main contexts for saving and ui updates
        
        persistingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        persistingContext.persistentStoreCoordinator = coordinator
        
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = persistingContext
        
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = context
        
        
        //initializing data base url
        let fileManager = FileManager.default
        
        guard let dbURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("data base url not found")
            return nil
        }
        
        self.dataBaseURL = dbURL.appendingPathComponent("\(name).sqlite")
        
        //options for migration
        let options = [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
        
        do {
            try addPersistentStoreCoordinator(nil, storeType: NSSQLiteStoreType, storeURL: dataBaseURL, options: options as [NSObject : AnyObject])
        } catch {
            print("can not add persistence store to coordiantor")
        }
        
        
    }
    
    // add persistent store
    func addPersistentStoreCoordinator(_ configuration: String?, storeType: String, storeURL: URL, options: [NSObject: AnyObject]) throws {
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
    }
    
    
}

extension CoreDataStack {
    
    // delete all conetnts of data model file, leave empty table
    func dropAll() throws {
        try coordinator.destroyPersistentStore(at: dataBaseURL , ofType: NSSQLiteStoreType, options: nil)
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dataBaseURL, options: nil)
    }
    
    // background batch operation
    typealias Batch = (_ workerContext: NSManagedObjectContext)-> Void
    
    func performBatchOperation(_ batch: @escaping Batch) {
        backgroundContext.perform {
            batch(self.backgroundContext)
            //try save background context
            
            do {
                try self.backgroundContext.save()
            }
            catch {
                fatalError("can not save to background context")
            }
        }
    }
    
    //saving
    func save() {
        context.perform {
            
            if self.context.hasChanges {
                
                do{
                   try self.context.save()
                }
                catch {
                    fatalError("cannot save to context")
                }
                
                self.persistingContext.perform {
                    do {
                        try self.persistingContext.save()
                    }
                    
                    catch {
                        fatalError("can not save to persisting context")
                    }
                }
            }
        }
    }
    
    //auto saving
    
    func autoSave(_ delaySecond: Int) {
        
        if delaySecond > 0 {
            do {
                try self.context.save()
            } catch {
                print("error while auto saving error")
            }
        }
        
        let delayInNanoSecond = UInt64(delaySecond) * NSEC_PER_SEC
        let time = DispatchTime.now() + Double(UInt64(delayInNanoSecond)) * Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: time, execute: { 
            self.autoSave(delaySecond)
        })
    }
    
}
