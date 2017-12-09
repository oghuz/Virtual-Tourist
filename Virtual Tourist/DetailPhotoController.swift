//
//  DetailPhotoController.swift
//  Virtual Tourist
//
//  Created by osmanjan omar on 3/28/17.
//  Copyright © 2017 osmanjan omar. All rights reserved.
//

import UIKit

class DetailPhotoController: UIViewController {
    
    var detailImage = UIImage()    
    var didHide: Bool = false

    @IBOutlet weak var imageView: UIImageView! {
        didSet{
            imageView.image = detailImage
        }
    }
    // tap geusture outlet
    
    @IBOutlet weak var tapGeusture :UITapGestureRecognizer! {
        didSet {
            tapGeusture.numberOfTapsRequired = 1
        }
    }
    
    //tap view controller for hiding and showing navigation bar
    @IBAction func tapController(_ sender: UITapGestureRecognizer) {
        
        didHide = !didHide
        showAndHide(didHide)
    }
    
    // hiding and showing navigation bar
    private func showAndHide(_ willHide: Bool) {
        self.navigationController?.setNavigationBarHidden(willHide, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		self.view.backgroundColor = .white
    }
 }


