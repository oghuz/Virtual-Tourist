//
//  CoreDataCollectionCollectionViewController.swift
//  Virtual Tourist
//
//  Created by osmanjan omar on 3/15/17.
//  Copyright © 2017 osmanjan omar. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "Cell"

class CoreDataCollectionCollectionViewController: UICollectionViewController {

    //#MARK: Initialization
    
    //creating fechedrequestcontroller
    var fetchResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            fetchResultsController?.delegate = self
            collectionView?.reloadData()
            executeSearch()
        }
    }
    
    //initializing
    init(fetchResultsController fc: NSFetchedResultsController<NSFetchRequestResult>, collectionViewLayout layout: UICollectionViewLayout) {
        self.fetchResultsController = fc
        super.init(collectionViewLayout: layout)
    }
    
    //required init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}

extension CoreDataCollectionCollectionViewController: NSFetchedResultsControllerDelegate {
    
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

extension CoreDataCollectionCollectionViewController {
    
    //execute search
    func executeSearch() {
        if let fr = fetchResultsController {
            do {
                try fr.performFetch()
            }
            catch let error as NSError {
                print("error while searching\(fetchResultsController), error: \(error)")
            }
        }
    }
    

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
