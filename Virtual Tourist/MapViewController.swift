//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by osmanjan omar on 3/6/17.
//  Copyright © 2017 osmanjan omar. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var didTapped = Bool() // set value for this bool by tapping edit button, for toggle editting mode
    let longPressGeusture = UILongPressGestureRecognizer()
    var reachability = Reachability()
    var coordination = CLLocationCoordinate2D()
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
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
    }
    
    //app life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    
    //add pin to map by long press
    @objc private func addPinByLongPress() {
        
        if longPressGeusture.state == .began {
            if (reachability?.isReachable)! {
                
                let points = longPressGeusture.location(in: mapView)
                coordination = mapView.convert(points, toCoordinateFrom: mapView)
                Helper.shared.addPinForCoordination(mapView, coordination: coordination)
                
                // calling get photo with coordination method
                Networking.shared.getPhotoWithCoordination(coordination: coordination, complitionHandlerForgetPhoto: { (result, error) in
                    guard (error == nil) else {
                        Helper.shared.alert(self, title: "Error", message: "No data found", preferredStyle: .alert, okActionTitle: nil, okActionStyle: nil, okActionHandler: nil, cancelActionTitle: "Dismiss", cancelActionStyle: .cancel, cancelActionHandler: nil)
                        return
                    }
                    
                    if let results = result {
                        print("total photos \(results.count)")
                    }
                })
                
            }
                // if there is no internet connection show an alert, can not add pin
            else{
                Helper.shared.alert(self, title: "No Internet Connection", message: "Please check your internet connection, disable airplane mode, activate WIFI", preferredStyle: .alert, okActionTitle: nil, okActionStyle: nil, okActionHandler: nil, cancelActionTitle: "Dismiss", cancelActionStyle: .cancel, cancelActionHandler: nil)
            }
        }
    }
    
}

extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        // perform segue to collection view controller
        performSegue(withIdentifier: "goToCollection", sender: MKAnnotationView())
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //sending coordination to collection view controller
        if segue.identifier == "goToCollection" {
        let collectionVC = segue.destination as? PhotoCollectionController
        
        collectionVC?.coordination = self.coordination
        
        }
    }


}

