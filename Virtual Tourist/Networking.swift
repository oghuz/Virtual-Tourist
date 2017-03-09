//
//  Networking.swift
//  Virtual Tourist
//
//  Created by osmanjan omar on 3/9/17.
//  Copyright © 2017 osmanjan omar. All rights reserved.
//

import Foundation


//all the networking code goes in this file
class Networking {

    //#MARK: Get Request
    
    
    
    //#MARK: URL from components
    
    func urlFromComponents(_ parameters: [String: AnyObject]?, withPathExtension: String?)-> URL {
    
        var components = URLComponents()
        components.host = Constants.URLConstants.hostName
        components.scheme = Constants.URLConstants.scheme
        components.path = Constants.URLConstants.path + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        if let parameters = parameters {
        
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems?.append(queryItem)
            
            }
        
        }
        
        return components.url!
        
    
    
    }
    
    
    //#MARK: json parser method
    
    
    
    //#MARK: Get photo url from components
    
    
    
    //#MARK: Get photo method

    



}
