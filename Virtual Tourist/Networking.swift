//
//  Networking.swift
//  Virtual Tourist
//
//  Created by osmanjan omar on 3/9/17.
//  Copyright © 2017 osmanjan omar. All rights reserved.
//

import Foundation
import MapKit


//all the networking code goes in this file
class Networking {

    //#MARK: Get Request task
    func getURLRequestTask(method apiMethod: String? ,parameters: [String: AnyObject]?, complitionHandlerForGet: @escaping(_ result: AnyObject?, _ error: Error? )->Void)-> URLSessionDataTask {
        
        let parameters = parameters
        
        let url = urlFromComponents(parameters, withPathExtension: apiMethod)
    
        let request = NSMutableURLRequest(url: url)
        request.addValue(Constants.APIparameterKey.ApplicationJson, forHTTPHeaderField: Constants.APIparameterValue.Accept)
        request.addValue(Constants.APIparameterKey.ApplicationJson, forHTTPHeaderField: Constants.APIparameterValue.ContentType)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            //error handling
            
            func sendError(_ error: String) {
                print("error: \(error)")
                let userInfo = [NSLocalizedDescriptionKey: error]
                complitionHandlerForGet(nil, NSError(domain: "getURLRequestTask", code: 0, userInfo: userInfo))
            }
            
            // checking for error
            guard (error == nil) else {
                sendError("\(error)")
                return
            }
            
            // checking for status code
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(" status code not in range \(error)")
                return
            }
            
            if let data = data  {
                //calling parse data method
                self.parseJsonDataWithComplitionHandler(data, complitionhandlerForParseData: complitionHandlerForGet)
            }
            else {
                sendError("No data returned \(error)")
            }
            
        }
    
        
        
        task.resume()
        return task
    }
    
    //#MARK: json parser method
    
    // take data from url request and closure that is passing bay get method and parse data, give result back into closue
    func parseJsonDataWithComplitionHandler(_ data: Data, complitionhandlerForParseData: (_ result: AnyObject?, _ error: Error?)->Void) {
    
        var parsedData: AnyObject? = nil
        
        do {
           parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: error]
            complitionhandlerForParseData(nil, NSError(domain: "parseJsonDataWithComplitionHandler", code: 1, userInfo: userInfo))
        }
        
        complitionhandlerForParseData(parsedData, nil)
    
    }
    
    
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
    
    
    //#MARK: Get photo url from components
    // https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg
    //contructs photo from standard photo response
    func constructPhotoWithResponse(farmID: String, serverID: String, PhotoID: String, photoSecrete: String)->URL {
    
        let photoURL = URL(string: "https://farm\(farmID).staticflickr.com/\(serverID)/\(PhotoID)_\(photoSecrete).jpg")
        return photoURL!
    }
    
    
    //#MARK: Get photo method

    func getPhotoWithCoordination(coordination: CLLocationCoordinate2D, complitionHandlerForgetPhoto: @escaping(_ photos: AnyObject?, _ error: Error)->Void) {
    
    
    
    }
    



}
