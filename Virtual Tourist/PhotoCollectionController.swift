//
//  PhotoCollectionControllerViewController.swift
//  Virtual Tourist
//
//  Created by osmanjan omar on 3/9/17.
//  Copyright © 2017 osmanjan omar. All rights reserved.
//

import UIKit
import MapKit

class PhotoCollectionController: UIViewController {
    
    // for toggle edit mode
    var didTapped = Bool()
    
    //coordination for pin also for lat, lon of flickr search string
    var coordination = CLLocationCoordinate2D()

    // @IBOutlet weak var collectionView: CollectionView!
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            Helper.shared.addPinForCoordination(mapView, coordination: coordination)
        }
    }
    
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var editButtonAction: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
}

extension PhotoCollectionController {

}
