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

    @IBOutlet weak var maoView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var editButtonAction: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
