//
//  UIUpdateOnMainQueue.swift
//  Virtual Tourist
//
//  Created by osmanjan omar on 3/19/17.
//  Copyright © 2017 osmanjan omar. All rights reserved.
//

import Foundation

func performUpdateOnMain(_ update: @escaping ()->Void) {
    
    DispatchQueue.main.async {
        update()
    }
}
