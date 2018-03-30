//
//  CollectionViewCell.swift
//  Virtual Tourist
//
//  Created by osmanjan omar on 3/19/17.
//  Copyright © 2017 osmanjan omar. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
	@IBOutlet weak var imageView: UIImageView! {
		didSet{
			setBackGround()
		}
	}
	
	func backGround() {
		imageView.backgroundColor = .gray
	func setBackGround() {
		imageView.backgroundColor = .cyan
		imageView.tintColor = .darkGray
	}
    
}

