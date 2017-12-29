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
    var inEditMode: Bool = false // in edit mode user can delete pins by tapping on it
    let longPressGeusture = UILongPressGestureRecognizer()
    var reachability = Reachability()
    var coordination = CLLocationCoordinate2D()
    
    //selected pin coordination
    var Selectedcoordination = CLLocationCoordinate2D()
    
    //appdelegate
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    
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
        UIView.animate(withDuration: 0.5) {
            Helper.shared.inEditMode(tapped: self.didTapped, view: self, barButton: self.editButton, statusLabel: self.tapToDeleteLabel)
        }
        inEditMode = !inEditMode
    }
    
    //#MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //set title for viewcontroller
        self.title = "Virtual Tourist"
        let coordinations = try? Helper.shared.getCoordinationFromCoreData()
       
        if let coordinates = coordinations {
            for item in coordinates {
                Helper.shared.addPinForCoordination(mapView, coordination: item)
            }
        }

        // printing out data base file location
        let directory = NSPersistentContainer.defaultDirectoryURL()
        let url = directory.appendingPathComponent("DataModel.sqlite")
        print(url)
    }
    
    //view will load
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let coordin = try? delegate.persistentContainer.viewContext.count(for: Coordination.fetchRequest()) {
            print("\(coordin) Coordinates are here")
        }
        
        if let photoCount = (try? Helper.shared.persistentContainer().viewContext.fetch(Photos.fetchRequest() as NSFetchRequest))?.count {
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
                Helper.shared.addPinForCoordination(mapView, coordination: coordination)
                
                //save coordination to core data
                let _ = Helper.shared.saveCoordinationToDataBase(withCoordination: coordination)
                
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
        //delete pin on map when in edit mode
        if inEditMode {
            if let annotation = view.annotation {
                try? Helper.shared.deleteCoordinate(annotation.coordinate)
                mapView.removeAnnotation(annotation)
            }
        } else {        
        // perform segue to collection view controller in non edit mode
        Selectedcoordination = (view.annotation?.coordinate)!
        performSegue(withIdentifier: "goToCollection", sender: MKAnnotationView())
        mapView.deselectAnnotation(view.annotation, animated: true)
        }
    }
    
    // mapview delegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseID = "PinID"
        var mapPin = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        if mapPin == nil {
            mapPin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            mapPin?.animatesDrop = true
            mapPin?.pinTintColor = .red
        }
        else {
            mapPin?.annotation = annotation
        }
        return mapPin
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {        
        //sending coordination to collection view controller
        if segue.identifier == "goToCollection" {
            let collectionVC = segue.destination as? PhotoCollectionViewController
            collectionVC?.coordination = self.Selectedcoordination
        }
    }
    
}

