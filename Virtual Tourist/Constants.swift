//
//  Constants.swift
//  Virtual Tourist
//
//  Created by osmanjan omar on 3/8/17.
//  Copyright © 2017 osmanjan omar. All rights reserved.
//

import Foundation

// all needed constants goes into this file
struct Constants {
        
    //constants for constructing url
    struct URLConstants {
        static let scheme = "https"
        static let hostName = "api.flickr.com"
        static let path = "/services/rest/"
        static let apiSecret = "c19eaf503b79abb9"
        static let pages = "pages"
            }
    
    
    //value from json parsing, used for making photo url
    struct PhoroParameterKeys {
        static let photoID = "id"
        static let secret = "secret"
        static let server = "server"
        static let farm = "farm"
        static let title = "title"
    }
    
    // API parameter key
    struct APIparameterKey {
        static let method = "method"
        static let apiKey = "api_key"
        static let latitude = "lat"
        static let longitude = "lon"
        static let radius = "radius"
        static let extras = "extras"
        static let perPage = "per_page"
        static let page = "page"
        static let ApplicationJson = "application/json"
        static let format = "format"
        static let jsonCallBack = "nojsoncallback"
    }
    
    // PAI parameter value
    struct APIparameterValue {
        
        static let apiKeyValue = "30eebc54834e0fcaeb75afe09afd991c"
        static let ContentType = "Content-Type"
        static let Accept = "Accept"
        static let extras = "m_url"
        static let json = "json"
        static let searchMethod = "flickr.photos.search"
        static let noJsonCallBack = "1"
    }
    
    //url response constants
    struct URLResponseKey {
        static let statusKey = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Page = "page"
        static let Pages = "pages"
    }
    
    struct URLResponseValue {
        static let statusValue = "ok"
    }
    
    
}
