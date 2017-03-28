//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by osmanjan omar on 3/6/17.
//  Copyright © 2017 osmanjan omar. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    //#MARK: Properties and Outlets
    
    var didTapped = Bool() // set value for this bool by tapping edit button, for toggle editting mode
    var inEditMode: Bool = false
    let longPressGeusture = UILongPressGestureRecognizer()
    var reachability = Reachability()
    var coordination = CLLocationCoordinate2D()
    
    //selected pin coordination
    var Selectedcoordination = CLLocationCoordinate2D()
    
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
            longPressGeusture.minimumPressDuration = 0.5
            longPressGeusture.numberOfTouchesRequired = 1
            longPressGeusture.addTarget(self, action: #selector(addPinByLongPress))
            mapView.addGestureRecognizer(longPressGeusture)
        }
    }
    
    @IBOutlet weak var editButton: UIBarButtonItem! {
        didSet {
            didTapped = false
        }
    }
    
    @IBOutlet weak var tapToDeleteLabel: UILabel! {
        didSet{
            self.tapToDeleteLabel?.alpha = 0.0
        }
    }
    
    // action that make window enter editing mode, in editing mode user can delete pins on map
    @IBAction func editPinActionButton(_ sender: UIBarButtonItem) {
        didTapped = !didTapped
        Helper.shared.inEditMode(tapped: didTapped, view: self, barButton: editButton, statusLabel: tapToDeleteLabel)
        inEditMode = !inEditMode
    }
    
    
    //#MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let coordinations = try? Helper.shared.getCoordinationFromCoreData()
        
        if let coordinates = coordinations {
            for item in coordinates {
                Helper.shared.addPinForCoordination(mapView, coordination: item)
            }
        }

        
    }
    
    //view will load
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let coordin = try? Helper.shared.stackManagedObjectContext().count(for: Coordination.fetchRequest()) {
            print("\(coordin) Coordinates are here")
        }

        
        if let photoCount = (try? Helper.shared.stackManagedObjectContext().fetch(Photos.fetchRequest() as NSFetchRequest))?.count {
            print("total \(photoCount) photos")
        }

    }
    
    //#MARK: ADD pin to map by long press
    @objc private func addPinByLongPress() {
        
        if longPressGeusture.state == .began {
            if (reachability?.isReachable)! {
                
                let points = longPressGeusture.location(in: mapView)
                coordination = mapView.convert(points, toCoordinateFrom: mapView)
                
                //add pin on mapview
                //Helper.shared.addPinForCoordination(mapView, coordination: coordination)
                
                //adding photo ad url to data base
                Helper.shared.savePhotoAndURLToDataBase(forCoordination: coordination, atMapview: self.mapView, withPageNumber:1 ,inView: self)
            }
                // if there is no internet connection show an alert, can not add pin
            else{
                performUpdateOnMain({
                    Helper.shared.alert(self, title: "No Internet Connection", message: "Please check your internet connection, disable airplane mode, activate WIFI", preferredStyle: .alert, okActionTitle: nil, okActionStyle: nil, okActionHandler: nil, cancelActionTitle: "Dismiss", cancelActionStyle: .cancel, cancelActionHandler: nil)                    
                })
            }
        }
    }
}

//#MARK: MKMapViewDelegate, prepare for segue

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        // perform segue to collection view controller
        Selectedcoordination = (view.annotation?.coordinate)!
        performSegue(withIdentifier: "goToCollection", sender: MKAnnotationView())
        mapView.deselectAnnotation(view.annotation, animated: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //sending coordination to collection view controller
        if segue.identifier == "goToCollection" {
            
            let collectionVC = segue.destination as? PhotoCollectionViewController
            collectionVC?.coordination = self.Selectedcoordination
        }
    }
    
}

