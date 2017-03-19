//
//  CoreDataCollectionCollectionViewController.swift
//  Virtual Tourist
//
//  Created by osmanjan omar on 3/15/17.
//  Copyright © 2017 osmanjan omar. All rights reserved.
//

import UIKit
import CoreData


class CoreDataCollectionViewController: UICollectionViewController {

    
    //creating fechedrequestcontroller
    var fetchResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            fetchResultsController?.delegate = self
            collectionView?.reloadData()
            executeSearch()
        }
    }
    
    //#MARK: Initialization
    init(fetchResultsController fc: NSFetchedResultsController<NSFetchRequestResult>, collectionViewLayout layout: UICollectionViewLayout) {
        self.fetchResultsController = fc
        super.init(collectionViewLayout: layout)
    }
    
    //required init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}

extension CoreDataCollectionViewController {

    //execute search
    func executeSearch() {
        if let fc = fetchResultsController {
            do {
                try fc.performFetch()
            }
            catch let error as NSError {
                print("error while searching\(fetchResultsController), error: \(error)")
            }
        }
    }

}

extension CoreDataCollectionViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.reloadData()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let sec = IndexSet(integer: sectionIndex)
        
        switch type {
        case .delete:
            collectionView?.deleteSections(sec)
        case .insert:
            collectionView?.insertSections(sec)
        case .update:
            collectionView?.reloadSections(sec)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            collectionView?.insertItems(at: [newIndexPath!])
        case .delete:
            collectionView?.deleteItems(at: [indexPath!])
        case .update:
            collectionView?.reloadItems(at: [indexPath!])
        default:
            //moving items is not needed
            break
        }
    }
}


// MARK: UICollectionViewDataSource
extension CoreDataCollectionViewController {
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if let fc = fetchResultsController {
            return (fc.sections?.count)!
        }
        else {
            return 0
        }
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fc = fetchResultsController {
            return fc.sections![section].numberOfObjects
        }
        else{
            return 0
        }
    }

    
    // create collection view items in sub classes
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("this method must be implemented in subclasse")
    }
   

}
