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
    
    //get total page number from userdefaults
    var totalPage: Int = 0
    
    //current page number
    var currentPage: Int = 1
    
    //index paths for deletion
    var selectedIndexPaths: [IndexPath]? = []
    
    //persistentStoreCoordinator
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer {
        didSet {
            //self.startFetching()
        }
    }
    
    //activity indicator
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView! {
        didSet{
            activitySpinner.hidesWhenStopped = true
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
    
    
    @IBOutlet weak var next_DeleteOutlet: UIButton! {
        didSet {
            next_DeleteOutlet.backgroundColor = .white
        }
        
    }
    
    
    // actions for  next and delete button
    
    
    @IBAction func next_DeleteOutlet(_ sender: UIButton) {
        
        if sender.titleLabel?.text == "Next Page" {
            
            guard currentPage < totalPage else {
                Helper.shared.alert(self, title: "", message: "No more photos in this location", preferredStyle: .alert, okActionTitle: nil, okActionStyle: nil, okActionHandler: nil, cancelActionTitle: "Dismiss", cancelActionStyle: .cancel, cancelActionHandler: nil)
                
                return
            }
            currentPage += 1
            print("--------------nextPage-------currentPage---: \(currentPage)")
            downloadImageForcurrentPage(currentPage: currentPage)
        }
        if (sender.titleLabel?.text == "Delete") && (selectedIndexPaths != nil) {
            print("indexpath befor sorting : \(String(describing: selectedIndexPaths))")
            //let sortedIndexPath = selectedIndexPaths?.
            
            //print("indexpath befor sorting : \(String(describing: sortedIndexPath))")
            
            deleteSelectedPhotos(atIndexPathes: selectedIndexPaths)
            selectedIndexPaths?.removeAll()
            
        }
    }
    
    
    // edit button for toggle between edit mode
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBAction func editButtonAction(_ sender: UIBarButtonItem) {
        didTapped = !didTapped
        
        performUpdateOnMain {
            Helper.shared.inEditMode(tapped: self.didTapped, view: self, barButton: self.editButton, statusLabel: nil)
        }
        
        //hide next button, show delete button
        if UIDevice.current.orientation.isLandscape || UIDevice.current.orientation.isPortrait {
            
            if didTapped {
                performUpdateOnMain {
                    self.buttonsInEditMode()
                }
            }
            
            if !didTapped {
                performUpdateOnMain {
                    self.buttonsNotIneditMode()
                }
            }
        }
    }
    
    //#MARK: Delete Phtots at Index Paths
    //delete photos at selected index path
    private func deleteSelectedPhotos(atIndexPathes indexPaths: [IndexPath]?) {
        if let indexPaths = indexPaths {
            
            //self.collectionView.deleteItems(at: indexPaths)
            deleteImageFromArray(atIndex: indexPaths)
            self.collectionView.reloadData()
        }
    }
    
    private func deleteImageFromArray(atIndex indexPath: [IndexPath]) {
        for index in indexPath {
            imageArray?.remove(at: index[1])
            print("the indexes : \(index[1])")
        }
    }
    
    
    //MARK: Download Images
    
    // dwonload data for current page
    private func downloadImageForcurrentPage(currentPage page: Int) {
        //starting activity indicator
        activitySpinner.startAnimating()
        DispatchQueue.global().async {
            Helper.shared.fetchOrDownloadImages(withPageNumber: page, atLocation: self.coordination, inView: self) { (photos) in
                if let images = photos {
                    self.imageArray = images
                    self.reloadDataOnMain()
                    
                }
            }
        }
    }
    
    @objc private func reloadDataOnMain() {
        //updating UI on main thread
        
        performUpdateOnMain {
            self.collectionView.reloadData()
            self.activitySpinner.stopAnimating()
            if let totalpage = UserDefaults.standard.value(forKey: Constants.URLConstants.totalPage) as? Int {
                self.totalPage = totalpage
                print("there are total \(String(describing: self.totalPage)) pages)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        performUpdateOnMain {
            //setting up button sizes
            self.setUpButtons()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadImageForcurrentPage(currentPage: currentPage)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //unRegisterNSManagedObjectContextdidChangeNotification()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if didTapped == true {
            buttonsInEditMode()
        } else {
            buttonsNotIneditMode()
        }
        //setUpButtons()
    }
    
    //notification center
    //register NSManagedObjectContext did change notification
    func registerNSManagedObjectContextdidChangeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDataOnMain), name: .NSManagedObjectContextObjectsDidChange, object: nil)
    }
    
    //remove NSManagedObjectContext did change notification
    func unRegisterNSManagedObjectContextdidChangeNotification() {
        NotificationCenter.default.removeObserver(self, name: .NSManagedObjectContextObjectsDidChange, object: nil)
    }
    
    
    //MARK: Setup Buttons methods
    //setup buttons initially
    private func setUpButtons() {
        
        if UIDevice.current.orientation.isLandscape || UIDevice.current.orientation.isPortrait {
            self.next_DeleteOutlet.frame.size.width = self.view.frame.size.width
        }
    }
    
    //setup buttons when in edit mode
    private func buttonsInEditMode() {
        UIView.animate(withDuration: 0.5, animations: {
            self.next_DeleteOutlet.titleLabel?.text = "Delete"
            self.next_DeleteOutlet.backgroundColor = .red
            self.next_DeleteOutlet.tintColor = .black
        })
    }
    
    //setup buttons when Not in edit mode
    private func buttonsNotIneditMode() {
        UIView.animate(withDuration: 0.5, animations: {
            self.next_DeleteOutlet.titleLabel?.text = "Next Page"
            self.next_DeleteOutlet.backgroundColor = .white
            self.next_DeleteOutlet.tintColor = .black
            
        })
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
        return (imageArray?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as! CollectionViewCell
        
        let imageItem = self.imageArray?[indexPath.item]
        if let item = imageItem {
            cell.imageView.image = item
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if !didTapped {
            if let image = imageArray?[indexPath.item] {
                imageForPass = image
            }
            performSegue(withIdentifier: "showPhoto", sender: collectionView.cellForItem(at: indexPath))
        } else {
            selectedIndexPaths?.append((collectionView.indexPathsForSelectedItems?[0])!)
            
            collectionView.cellForItem(at: indexPath)?.alpha = 0.5
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
        }
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






