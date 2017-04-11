//
//  AlertViewController.swift
//  Virtual Tourist
//
//  Created by osmanjan omar on 3/7/17.
//  Copyright © 2017 osmanjan omar. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class Helper {
    
    //shared instance of this class
    static let shared = Helper()
    
    //userdefaults for total page
    lazy var defaults = UserDefaults.standard
    
    
    
    //#MARK: AlertViewController
    //Reusable method for AlertViewController
    func alert(_ view: UIViewController, title: String?, message: String?, preferredStyle: UIAlertControllerStyle, okActionTitle: String?, okActionStyle: UIAlertActionStyle?, okActionHandler: ((UIAlertAction) -> Void)?, cancelActionTitle: String?, cancelActionStyle: UIAlertActionStyle?, cancelActionHandler: ((UIAlertAction) -> Void)?) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        if let okActionStyle = okActionStyle {
            let okAction = UIAlertAction(title: okActionTitle, style: okActionStyle, handler: okActionHandler)
            alertController.addAction(okAction)
        }
        if let cancelActionStyle = cancelActionStyle {
            let cancelAction = UIAlertAction(title: cancelActionTitle, style: cancelActionStyle, handler: cancelActionHandler)
            alertController.addAction(cancelAction)
        }
        
        view.present(alertController, animated: true, completion: nil)
        
    }
    
    //#MARK: Add Pin
    // add map pin on mapview by coordination
    func addPinForCoordination(_ mapView: MKMapView ,coordination: CLLocationCoordinate2D?) {
        
        if let coordination = coordination {
            let pin = MKPointAnnotation()
            let span = MKCoordinateSpanMake(3.0, 3.0)
            let region = MKCoordinateRegionMake(coordination, span)
            pin.coordinate = coordination
            mapView.setRegion(region, animated: true)
            mapView.addAnnotation(pin)
        }
    }
    
    
    //#MARK: Edit mode Toggle
    // this method is for left leftBarButtonItem only so far, can be added extra code for both sides
    func inEditMode(tapped buttonTapped: Bool, view: UIViewController, barButton: UIBarButtonItem?, statusLabel: UILabel?) {
        
        if buttonTapped {
            barButton?.tintColor = .red
            barButton?.title = "Done"
            view.navigationItem.rightBarButtonItem = barButton
            statusLabel?.alpha = 1.0
        }
        if !buttonTapped {
            barButton?.tintColor = .blue
            barButton?.title = "Edit"
            view.navigationItem.rightBarButtonItem = barButton
            statusLabel?.alpha = 0.0
        }
    }
    
    //#MARK: get NSManagedObjectContext
    func persistentContainer() -> NSPersistentContainer {
        
        // core data stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let container = delegate.persistentContainer
        
        return container
    }
    
    
    //#MARK: Fetch or Download Images
    func fetchOrDownloadImages(withPageNumber pageNumber: Int, atLocation location: CLLocationCoordinate2D, inView: UIViewController, imagedTobeSaved: @escaping (_ images: [UIImage]?)-> Void) {
        
        
        if let imageFromDataBase = try? getPhotoFromCoreData(withCoordination: location, pageNumber: pageNumber), (imageFromDataBase?.count)! > 0 {
            
            imagedTobeSaved(imageFromDataBase)
            
        } else {
            downloadPhotoWithCoordination(forCoordination: location, withPageNumber: pageNumber, inView: inView, uRlsAndPages: { (urls, totalpages) in
                var tempImageArray: [UIImage] = []
                if let urls = urls {
                    for url in urls {
                        let image = self.imageFromUrl(url)
                        tempImageArray.append(image!)
                    }
                    
                    imagedTobeSaved(tempImageArray)
                    
                    //saving total page information to userdefaults
                    if let totalPage = totalpages {
                        self.defaults.set(totalPage, forKey: Constants.URLConstants.totalPage)
                    }
                    
                    print("++++++++++++++++++ number of urls in fetchOrDownloadImages: \(urls.count)")
                    print("++++++++++++++++++ number of tempImageArray in fetchOrDownloadImages: \(tempImageArray.count)")
                    
                    //saving photos to data base with properties
                    self.saveImagesWithCoordination(location, urls, pageNumber: pageNumber)
                    
                }
            })
        }
        
    }
    
    
    //#MARK: Save Photo, ULR, Coordination To CoreData
    func downloadPhotoWithCoordination(forCoordination coordination: CLLocationCoordinate2D, withPageNumber page: Int ,inView: UIViewController, uRlsAndPages: @escaping (_ urls: [String]?, _ totalPages: Int?)->Void) {
        
        // calling get photo with coordination method
        Networking.shared.getPhotoWithCoordination(coordination: coordination, withPageNumber: page, complitionHandlerForgetPhoto: { (urlStrings, totalPage ,error) in
            
            guard (error == nil) else {
                Helper.shared.alert(inView, title: "Error", message: "No data found", preferredStyle: .alert, okActionTitle: nil, okActionStyle: nil, okActionHandler: nil, cancelActionTitle: "Dismiss", cancelActionStyle: .cancel, cancelActionHandler: nil)
                return
            }
            
            guard ((urlStrings?.count)! > 0) else {
                performUpdateOnMain {
                    Helper.shared.alert(inView, title: "No Photo", message: "No Photo Found On This Location", preferredStyle: .alert, okActionTitle: nil, okActionStyle: nil, okActionHandler: nil, cancelActionTitle: "Dismiss", cancelActionStyle: .cancel, cancelActionHandler: nil)
                }
                return
            }
            
            guard let uRls = urlStrings else {
                print("No photo or url fiund")
                return
            }
            
            uRlsAndPages(uRls, totalPage)
        })
        
    }
    
    
    //#MARK: Save coordination with Images
    
    //saving coordination
    
    func saveCoordinationToDataBase(withCoordination coordination: CLLocationCoordinate2D) {
        //creating coordination entity
        _ = Coordination(coordination.latitude, coordination.longitude, context: (self.persistentContainer().viewContext))
            /*
        self.persistentContainer().viewContext.perform {
            try? self.persistentContainer().viewContext.save()
        }
            */
        
    }
    func saveImagesWithCoordination(_ coordination: CLLocationCoordinate2D, _ urls: [String], pageNumber: Int) {
        
        if let coordinate = fetchCoordinationWithCoordinate(withCoordinate: coordination) {
            print("------------------hey there are saved coordinates here \(coordinate)")
            
            self.persistentContainer().performBackgroundTask{ [weak self] context in
                
                
                for urlString in urls {
                    let image = self?.imageFromUrl(urlString)
                    if let image = image {
                        let photo = Photos(NSData(data: UIImageJPEGRepresentation(image, 1.0)!), withURL: urlString, context: (self?.persistentContainer().viewContext)!)
                        coordinate.addToPhotos(photo)
                        photo.toCoordination?.latitude = coordinate.latitude
                        photo.toCoordination?.longitude = coordinate.longitude
                        photo.url = urlString
                        photo.pagenumber = Int16(pageNumber)
                        context.perform {
                            try? context.save()
                            print("------------------saving in saveImagesWithCoordination")
                            
                        }

                    }
                }
            }
        }
    }
    
    
    //constructing UIImage from URL
    func imageFromUrl(_ urlString: String) -> UIImage? {
        var photoData = Data()
        let url = URL(string: urlString)
        do {
            if let url = url {
                photoData = try Data(contentsOf: url)
            }
        } catch let e as NSError {
            print("can not get image from data, error :\(e)")
        }
        
        let image = UIImage(data: photoData)
        
        return image
    }
    
    
    //#MARK: loading coordination from core data
    
    //coordinations for mapview
    func getCoordinationFromCoreData() throws -> [CLLocationCoordinate2D] {
        
        let request: NSFetchRequest<Coordination> = Coordination.fetchRequest()
        var coordinate: [CLLocationCoordinate2D] = []
        do {
            let pins = try persistentContainer().viewContext.fetch(request)
            if pins.count > 0 {
                for item in pins {
                    let latlon = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
                    coordinate.append(latlon)
                }
            }
        } catch {
            throw error
        }
        
        return coordinate
        
    }
    
    //#MARK: loading photos from core data
    
    //get photo from core data with coordination
    func getPhotoFromCoreData(withCoordination coordination: CLLocationCoordinate2D, pageNumber: Int) throws -> [UIImage]? {
        
        //getting coordinates from core data for use predicate in photo
        let request: NSFetchRequest<Photos> = Photos.fetchRequest()
        if let coord = fetchCoordinationWithCoordinate(withCoordinate: coordination) {
            request.predicate = NSPredicate(format: "toCoordination = %@ and pagenumber = %i", argumentArray: [coord, pageNumber])
            print("!!!!!!!!!!!!!!! have coord for getPhotoFromCoreData \(coord)")
        }
        else {
            print("????????????????? Not have coord for getPhotoFromCoreData")
        }
        
        //array will be populate from fetch result
        var imageArray: [UIImage] = []
        
        do {
            let photoData = try persistentContainer().viewContext.fetch(request)
            if photoData.count > 0 {
                for item in photoData {
                    if let image = UIImage(data: item.photo! as Data) {
                        imageArray.append(image)
                    }
                }
            }
        } catch {
            throw error
        }
        
        return imageArray
    }
    
    
    //fetch coordination from core data for fetching matching photo
    func fetchCoordinationWithCoordinate(withCoordinate coordinate: CLLocationCoordinate2D) -> Coordination? {
        
        let pinRequest: NSFetchRequest<Coordination> = Coordination.fetchRequest()
        pinRequest.predicate = NSPredicate(format: "latitude = %@ and longitude = %@", argumentArray: [coordinate.latitude, coordinate.longitude])
        
        
        var coord: Coordination?
        
        do {
            
            let coordination = try persistentContainer().viewContext.fetch(pinRequest)
            if let coordin = coordination.first {
                
                //for faulting purpose
                _ = coordin.latitude
                _ = coordin.longitude
                
                coord = coordin
            }
            
        } catch {
            print("there is an error :\(error)", NSError(domain: "fetchCoordinationWithCoordinate", code: 0, userInfo: [NSLocalizedDescriptionKey: error]))
        }
        print("------fetchCoordinationWithCoordinate---- \(coord!)")
        return coord
    }
    
    
    //delete coordinate with pin coordinate
    func deleteCoordinate(_ coordinate: CLLocationCoordinate2D) throws {
        
        if let coordinate = fetchCoordinationWithCoordinate(withCoordinate: coordinate) {
            self.persistentContainer().viewContext.delete(coordinate as NSManagedObject)
                /*
            persistentContainer().viewContext.perform {
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            }
                */
        }
        
    }
    
    
    
}
