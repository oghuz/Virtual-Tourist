//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by osmanjan omar on 3/19/17.
//  Copyright © 2017 osmanjan omar. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PhotoCollectionViewController: UIViewController {
    
    var didTapped = Bool()
    
    //coordination for pin also for lat, lon of flickr search string
    var coordination = CLLocationCoordinate2D()
    
    //creating fechedrequestcontroller
    var fetchResultsController: NSFetchedResultsController<Photos>? {
        didSet {
            fetchResultsController?.delegate = self
            collectionView?.reloadData()
            executeSearch()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            Helper.shared.addPinForCoordination(mapView, coordination: coordination)
        }
    }
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBAction func editButtonAction(_ sender: UIBarButtonItem) {
        didTapped = !didTapped
        Helper.shared.inEditMode(tapped: didTapped, view: self, barButton: editButton, statusLabel: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        
    }
    
}

extension PhotoCollectionViewController {
    
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

extension PhotoCollectionViewController {
    // setting up collection view items spacing and size with different orientation
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation) {
            self.flowlayOut(spacee: 10, numberOfItems: 3)
        }
        else
        {
            self.flowlayOut(spacee: 10, numberOfItems: 5)
        }
    }
    
    // reusable func for configuring collection item
    func flowlayOut(spacee:CGFloat, numberOfItems:CGFloat){
        
        let space : CGFloat = spacee
        let numberOfItem : CGFloat = numberOfItems
        let itemDimention = (self.view.frame.size.width - ( (numberOfItem - 1) * space )) / numberOfItem
        
        flowLayout.minimumLineSpacing = space
        flowLayout.minimumInteritemSpacing = space
        flowLayout.itemSize = CGSize(width: itemDimention, height: itemDimention)
    }
    
}

extension PhotoCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let reuseID = "Cell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath)
        
        return cell
    }
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}

extension PhotoCollectionViewController: NSFetchedResultsControllerDelegate {
    
    // for automatically update collection view if data base changes
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





