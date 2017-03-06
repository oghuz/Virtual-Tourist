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
    
    @IBOutlet weak var mapView: MKMapView!
    
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

