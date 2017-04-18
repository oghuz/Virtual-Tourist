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
    
    // creating a singleton object for convinience
    static let shared = Networking()
    
    //#MARK: Get Request task
    func getRequestTask(parameters: [String: AnyObject], complitionHandlerForGet: @escaping(_ result: AnyObject?, _ error: Error? ) -> Void ) -> URLSessionDataTask {
        
        let parameters = parameters
        
        let url = urlFromComponents(parameters)
        
        let request = NSMutableURLRequest(url: url)
        request.addValue(Constants.APIparameterKey.ApplicationJson, forHTTPHeaderField: Constants.APIparameterValue.Accept)
        request.addValue(Constants.APIparameterKey.ApplicationJson, forHTTPHeaderField: Constants.APIparameterValue.ContentType)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            //error handling
            func sendError(_ errorr: String) {
                print("error: \(errorr)")
                let userInfo = [NSLocalizedDescriptionKey: errorr]
                complitionHandlerForGet(nil, NSError(domain: "getURLRequestTask", code: 0, userInfo: userInfo))
            }
            
            // checking for error
            guard (error == nil) else {
                if let error = error {
                    sendError("\(error)")
                }
                return
            }
            
            // checking for status code
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                
                if let error = error {
                    sendError(" status code not in range \(error)")
                }
                return
            }
            
            if let data = data  {
                //calling parse data method
                self.parseJsonDataWithComplitionHandler(data, complitionhandlerForParseData: complitionHandlerForGet)
            }
            else {
                if let error = error {
                    sendError("No data returned \(error)")
                }
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
            
            complitionhandlerForParseData(nil, error)
        }
        complitionhandlerForParseData(parsedData, nil)
    }
    
    //#MARK: URL from components
    
    func urlFromComponents(_ parameters: [String: AnyObject]) -> URL {
        
        var components = URLComponents()
        components.host = Constants.URLConstants.hostName
        components.scheme = Constants.URLConstants.scheme
        components.path = Constants.URLConstants.path
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems?.append(queryItem)
        }
        
        return components.url!
        
    }
    
    
    //#MARK: Get photo method
    
    func getPhotoWithCoordination(coordination: CLLocationCoordinate2D?, withPageNumber page: Int? ,complitionHandlerForgetPhoto: @escaping( _ photoURL_ID: [[Int: String]]?, _ totalPage: Int? ,_ error: Error? ) -> Void ) {
        
        // lat, lon for photo search
        let latitude = coordination?.latitude
        let longitude = coordination?.longitude
        
        // parameters for url
        let parameters = [Constants.APIparameterKey.apiKey: Constants.APIparameterValue.apiKeyValue as AnyObject,
                          Constants.APIparameterKey.latitude: latitude as AnyObject,
                          Constants.APIparameterKey.longitude: longitude as AnyObject,
                          Constants.APIparameterKey.radius: 5 as AnyObject,
                          Constants.APIparameterKey.method: Constants.APIparameterValue.searchMethod as AnyObject,
                          Constants.APIparameterKey.format: Constants.APIparameterValue.json as AnyObject,
                          Constants.APIparameterKey.jsonCallBack: Constants.APIparameterValue.noJsonCallBack as AnyObject,
                          Constants.APIparameterKey.page: page as AnyObject,
                          Constants.APIparameterKey.perPage: 20 as AnyObject,
                          Constants.APIparameterKey.safeSearch: 1,
                          Constants.APIparameterKey.extras: Constants.APIparameterValue.extras as AnyObject] as [String : AnyObject]
        
        //call get method
        let _ = getRequestTask(parameters: parameters) { (results, error) in
            
            // error checking
            guard (error == nil) else {
                
                complitionHandlerForgetPhoto(nil, nil, error)
                return
            }
            
            // creating a image array
            var urlStringArray: [[Int: String]] = []
            var totalPage = Int()
            
            // taking data
            if let data = results, let photosDictionary = data[Constants.URLResponseKey.Photos] as? [String: AnyObject], let pages = photosDictionary[Constants.URLConstants.totalPage] as? Int ,let photoURLDicArray = photosDictionary[Constants.URLResponseKey.Photo] as? [Dictionary<String, AnyObject>] {
                
                //assign total page
                totalPage = pages
                
                // limiting max number of array to 200
                // let limitedItemArray = (photoDicArray.count >= 200) ? Array([photoDicArray.prefix(upTo: 200)]) : photoDicArray
                
                for urlComponents in photoURLDicArray {
                    if let photoUrl = self.photoURLFromDataArray(urlComponents) {
                        urlStringArray.append(photoUrl)
                    }
                }
                complitionHandlerForgetPhoto(urlStringArray, totalPage, nil)
            }
        }
    }
    
    //#MARK: Get photo url from components
    
    //take dictionary array as parameter, return image as anyobject
    func photoURLFromDataArray(_ array: [String: AnyObject]) -> [Int: String]? {
        
        var photoURLString = String()
        //unwrapping photo parameters
        guard let farmID = array[Constants.PhotoParameterKeys.farm] as? Int, let serverID = array[Constants.PhotoParameterKeys.server] as? String, let photoId = array[Constants.PhotoParameterKeys.photoID] as? Int,let photoID = array[Constants.PhotoParameterKeys.photoID] as? String, let secret = array[Constants.PhotoParameterKeys.secret] as? String else {
            
            return nil
        }
        
        photoURLString =  constructPhotoWithResponse(farmID: farmID, serverID: serverID, PhotoID: photoID, photoSecrete: secret )
        
        return [photoId:photoURLString]
    }
    
    //contructs photo from standard photo response
    func constructPhotoWithResponse(farmID: Int, serverID: String, PhotoID: String, photoSecrete: String ) -> String {
        //calling getPhotowith coordinate method
        let photoURL = "https://farm\(farmID).staticflickr.com/\(serverID)/\(PhotoID)_\(photoSecrete).jpg"
        return photoURL
    }
    
    
    
}
