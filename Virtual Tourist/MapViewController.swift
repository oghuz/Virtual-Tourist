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
    let reachability = Reachability()
    
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
        inEditMode(tapped: didTapped)
    }
    
    
    //add pin to map by long press
    @objc private func addPinByLongPress() {
        
        if longPressGeusture.state == .began {
            if (reachability?.isReachable)! {
                
                let points = longPressGeusture.location(in: mapView)
                let coordination = mapView.convert(points, toCoordinateFrom: mapView)
                let pin = MKPointAnnotation()
                let span = MKCoordinateSpanMake(0.2, 0.2)
                let region = MKCoordinateRegionMake(coordination, span)
                pin.coordinate = coordination
                mapView.setRegion(region, animated: true)
                mapView.addAnnotation(pin)
                
            }
                // if there is no internet connection show an alert, can not add pin
            else{
                Alert.shared.alert(self, title: "No Internet Connection", message: "Please check your internet connection, disable airplane mode, activate WIFI", preferredStyle: .alert, okActionTitle: nil, okActionStyle: nil, okActionHandler: nil, cancelActionTitle: "Dismiss", cancelActionStyle: .cancel, cancelActionHandler: nil)
            }
            
        }
        
    }
    
    // toggle changes for button title, color and button label's alpha based on button tap
    private func inEditMode(tapped buttonTapped: Bool) {
        if buttonTapped {
            editButton.tintColor = .red
            editButton.title = "Done"
            navigationItem.rightBarButtonItem = editButton
            tapToDeleteLabel.alpha = 1.0
        }
        if !buttonTapped {
            editButton.tintColor = .blue
            editButton.title = "Edit"
            navigationItem.rightBarButtonItem = editButton
            tapToDeleteLabel.alpha = 0.0
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
}

