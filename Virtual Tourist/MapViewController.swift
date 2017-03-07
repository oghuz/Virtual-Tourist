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
    
    var didTapped = Bool()
    let longPressGeusture = UILongPressGestureRecognizer()
    
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
    
    @IBAction func editPinActionButton(_ sender: UIBarButtonItem) {
        didTapped = !didTapped
        inEditMode(tapped: didTapped)
    }
    
    @objc private func addPinByLongPress() {
        
        if longPressGeusture.state == .began {
        
        let points = longPressGeusture.location(in: mapView)
        let coordination = mapView.convert(points, toCoordinateFrom: mapView)
        let pin = MKPointAnnotation()
        let span = MKCoordinateSpanMake(0.2, 0.2)
        let region = MKCoordinateRegionMake(coordination, span)
        pin.coordinate = coordination
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(pin)
        print("Coordinates \(coordination.latitude), \(coordination.longitude)")
        print("Long pressed the screen")
            
        }
        
    }
    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

