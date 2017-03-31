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

private let reuseID = "Cell"

class PhotoCollectionViewController: UIViewController {
    
    var didTapped: Bool = false
    
    //coordination for pin also for lat, lon of flickr search string
    var coordination = CLLocationCoordinate2D()
    var imageArray: [UIImage]? = []
    //detail image for detail image controller
    var imageForPass = UIImage()
    
    //persistentStoreCoordinator
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer {
        didSet {
            //self.startFetching()
        }
    }
    
    //creating fechedrequestcontroller
    var fetchResultsController: NSFetchedResultsController<Photos>?
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            //self.startFetching()
        }
    }
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            Helper.shared.addPinForCoordination(mapView, coordination: coordination)
        }
    }
    
    //privious, next, delete buttons
    @IBOutlet weak var priviousOutlet: UIButton! {
        didSet {
            priviousOutlet.backgroundColor = .white
        }
    }
    
    @IBOutlet weak var nextOutlet: UIButton! {
        didSet {
            nextOutlet.backgroundColor = .white
        }
        
    }
    
    @IBOutlet weak var deleteOutlet: UIButton! {
        didSet {
            deleteOutlet.backgroundColor = .red
            deleteOutlet.tintColor = .black
            deleteOutlet.alpha = 0.0
        }
    }
    
    // actions for privious, next and delete button
    
    @IBAction func priviousPage(_ sender: UIButton) {
    }
    
    @IBAction func nextPage(_ sender: UIButton) {
    }
    
    @IBAction func deleteImage(_ sender: UIButton) {
    }
    
    // edit button for toggle between edit mode
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBAction func editButtonAction(_ sender: UIBarButtonItem) {
        didTapped = !didTapped
        Helper.shared.inEditMode(tapped: didTapped, view: self, barButton: editButton, statusLabel: nil)
        
        //hide privious and next button, show delete button
        if didTapped {
            priviousOutlet.alpha = 0.0
            nextOutlet.alpha = 0.0
            deleteOutlet.alpha = 1.0
        }
        
        if !didTapped {
            priviousOutlet.alpha = 1.0
            nextOutlet.alpha = 1.0
            deleteOutlet.alpha = 0.0
        }
    }
    
    // start fetching if context has change
    func startFetching() {
        //getting coordinates from core data for use predicate in photo
        if let context = container?.viewContext {
            
            let request: NSFetchRequest<Photos> = Photos.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "photo", ascending: true)]
            
            if let coord = Helper.shared.fetchCoordinationWithCoordinate(withCoordinate: coordination) {
                request.predicate = NSPredicate(format: "toCoordination = %@", argumentArray: [coord])
            }
            
            fetchResultsController = NSFetchedResultsController<Photos>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultsController?.delegate = self
            if (container?.viewContext.hasChanges)! {
                executeSearch()
            }
            collectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let uiImages = try? Helper.shared.getPhotoFromCoreData(withCoordination: coordination)
        if let images = uiImages {
            imageArray = images
            
            self.collectionView.reloadData()
        }
        
        print("there are \(String(describing: imageArray?.count))) photos at coordination: \(coordination) ")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // startFetching()
        
    }
    
}


//MARK: Load Data With NSFetchedResultsController
extension PhotoCollectionViewController {
    
    //execute search
    func executeSearch() {
        if let fc = fetchResultsController {
            do {
                try fc.performFetch()
            }
            catch let error as NSError {
                print("error while searching\(fc), error: \(error)")
            }
        }
    }
    
}


//MARK: Setup UICollectionViewFlowLayout
extension PhotoCollectionViewController {
    // setting up collection view items spacing and size with different orientation
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation) {
            self.flowlayOut(spacee: 2, numberOfItems: 3)
        }
        else
        {
            self.flowlayOut(spacee: 2, numberOfItems: 5)
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


//MARK: UICollectionViewDataSource, UICollectionViewDelegate
extension PhotoCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        /*
        if let fc = fetchResultsController {
            return (fc.sections?[section].numberOfObjects)!
        }
        else {
            return 0
        }
 */
        return (imageArray?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as! CollectionViewCell
       /*
        if let imageData = fetchResultsController?.object(at: indexPath) {
            
            if let image = UIImage(data: (imageData.photo as Data?)!) {
                cell.imageView.image = image
                imageArray?.append(image)
            }
            
            
        }
        */
        
         let imageItem = imageArray?[indexPath.item]
         
         if let item = imageItem {
         cell.imageView.image = item
         }
         
 
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let image = imageArray?[indexPath.item] {
            imageForPass = image
        }
        performSegue(withIdentifier: "showPhoto", sender: collectionView.cellForItem(at: indexPath))
    }
    
}

//MARK: Prepare for segue

extension PhotoCollectionViewController {
    
    // passing image to detail view controller
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhoto" {
            let destination = segue.destination as? DetailPhotoController
            destination?.detailImage = imageForPass
        }
    }
    
}


//MARK: NSFetchedResultsControllerDelegate
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
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.reloadData()
    }
    
    
}





