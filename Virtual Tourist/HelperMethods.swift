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
    
    static let shared = Helper()
    
    //report for if there is data for this location
    
    
    
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
    
    
    //#MARK: Save Photo, ULR, Coordination To CoreData
    func savePhotoAndURLToDataBase(forCoordination coordination: CLLocationCoordinate2D, atMapview: MKMapView?, withPageNumber page: Int ,inView: UIViewController) {
        
        
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
            
            //adding pin to mapview, if there are photos at that coordination
            performUpdateOnMain {
                self.addPinForCoordination(atMapview!, coordination: coordination)
            }
            
            // adding coordinate to data base
            let coordinate = Coordination(coordination.latitude, coordination.longitude, context: self.persistentContainer().viewContext)
            self.persistentContainer().viewContext.perform({
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            })
            
            guard let uRls = urlStrings else {
                print("No photo or url fiund")
                return
            }
            
            print("total url \(uRls.count)")
            
            //saving photos to core data as NSData
            
            self.persistentContainer().performBackgroundTask{ [weak self] context in
                for urlString in uRls {
                    
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
                    if let image = image {
                        let photo = Photos(NSData(data: UIImageJPEGRepresentation(image, 1.0)!), withURL: urlString, context: (self?.persistentContainer().viewContext)!)
                        coordinate.addToPhotos(photo)
                        photo.toCoordination?.latitude = coordinate.latitude
                        photo.toCoordination?.longitude = coordinate.longitude
                        photo.url = urlString
                        context.perform {
                            try? context.save()
                        }
                        
                    }
                }
                
            }
        })
    }
    
    
    //#MARK: loading coordination from core data
    
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
    func getPhotoFromCoreData(withCoordination coordination: CLLocationCoordinate2D) throws -> [UIImage] {
        
        //getting coordinates from core data for use predicate in photo
        let request: NSFetchRequest<Photos> = Photos.fetchRequest()
        if let coord = fetchCoordinationWithCoordinate(withCoordinate: coordination) {
            request.predicate = NSPredicate(format: "toCoordination = %@", argumentArray: [coord])
            print("-----getPhotoFromCoreData----- coord :\(coord)")
        }
        //array will be populate from fetch result
        var imageArray: [UIImage] = []
        
        do {
            let photoData = try persistentContainer().viewContext.fetch(request)
            print("-----getPhotoFromCoreData----- photoData :\(photoData)")
            
            if photoData.count > 0 {
                print("-----photoData count :\(photoData.count)")
                for item in photoData {
                    if let image = UIImage(data: item.photo! as Data) {
                        imageArray.append(image)
                    }
                }
            }
        } catch {
            throw error
        }
        print("-----getPhotoFromCoreData----- imageArray :\(imageArray.count)")
        
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
            persistentContainer().viewContext.perform {
                self.persistentContainer().viewContext.delete(coordinate as NSManagedObject)
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            }
        }
        
    }
    
    
    
}
