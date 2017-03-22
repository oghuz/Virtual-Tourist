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
            let span = MKCoordinateSpanMake(0.2, 0.2)
            let region = MKCoordinateRegionMake(coordination, span)
            pin.coordinate = coordination
            mapView.setRegion(region, animated: true)
            mapView.addAnnotation(pin)
        }
    }
    
    
    //#MARK: Edit mode Toggle
    // this method is for left leftBarButtonItem only so far, can be added extra code for both sides
    func inEditMode(tapped buttonTapped: Bool, view: UIViewController, barButton: UIBarButtonItem, statusLabel: UILabel?) {
        
        if buttonTapped {
            barButton.tintColor = .red
            barButton.title = "Done"
            view.navigationItem.rightBarButtonItem = barButton
            statusLabel?.alpha = 1.0
        }
        if !buttonTapped {
            barButton.tintColor = .blue
            barButton.title = "Edit"
            view.navigationItem.rightBarButtonItem = barButton
            statusLabel?.alpha = 0.0
        }
    }
    
    //#MARK: get NSManagedObjectContext
    func stackManagedObjectContext() -> NSManagedObjectContext {
        
        // core data stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        return (stack?.context)!
        
    }
    
    //#MARK: Save Photo, ULR To CoreData
    func savePhotoAndURLToDataBase(forCoordination coordination: CLLocationCoordinate2D, withPageNumber page: Int ,inView: UIViewController) {
        // core data stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        // adding coordinate to data base
        let coordinate = Coordination(coordination.latitude, coordination.longitude, context: stackManagedObjectContext())
        stackManagedObjectContext().perform {
            (UIApplication.shared.delegate as! AppDelegate).stack?.save()
        }
        if let coordin = try? stackManagedObjectContext().count(for: Coordination.fetchRequest()) {
            print("\(coordin) Coordinates are here")
        }
        
        // calling get photo with coordination method
        Networking.shared.getPhotoWithCoordination(coordination: coordination, withPageNumber: page, complitionHandlerForgetPhoto: { (result, urlStrings, totalPage ,error) in
            
            guard (error == nil) else {
                Helper.shared.alert(inView, title: "Error", message: "No data found", preferredStyle: .alert, okActionTitle: nil, okActionStyle: nil, okActionHandler: nil, cancelActionTitle: "Dismiss", cancelActionStyle: .cancel, cancelActionHandler: nil)
                return
            }
            
            guard ((result?.count)! > 0) else {
                
                performUpdateOnMain({
                    Helper.shared.alert(inView, title: "No Photo", message: "No Photo Found On This Location", preferredStyle: .alert, okActionTitle: nil, okActionStyle: nil, okActionHandler: nil, cancelActionTitle: "Dismiss", cancelActionStyle: .cancel, cancelActionHandler: nil)
                })
                return
            }
            
            guard let results = result, let uRls = urlStrings else {
                print("No photo or url fiund")
                return
            }
            
            
            print("total photos \(uRls.count)")
            
            for photo in results {
                //saving photos to core data as NSData
                for url in uRls {
                    stack?.performBatchOperation({ (workerContext) in
                        let photo = Photos(NSData(data: UIImageJPEGRepresentation(photo, 1.0)!), context: self.stackManagedObjectContext())
                        coordinate.addToPhotos(photo)
                        photo.toCoordination = coordinate
                        photo.url = String(describing: url)
                    })
                }
            }
        })
    }
    
    
    //#MARK: loading coordination from core data
    
    func getCoordinationFromCoreData() throws -> [CLLocationCoordinate2D] {
        
        let request: NSFetchRequest<Coordination> = Coordination.fetchRequest()
        var coordinate: [CLLocationCoordinate2D] = []
        do {
            let pins = try stackManagedObjectContext().fetch(request)
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
    
    func getPhotoFromCoreData(withCoordination coordination: CLLocationCoordinate2D) throws -> [UIImage] {
        
        let request: NSFetchRequest<Photos> = Photos.fetchRequest()        
        request.predicate = NSPredicate(format: "toCoordination.latitude = %@ and toCoordination.longitude = %@", coordination.latitude, coordination.longitude)
        
        //array will be populate from fetch result
        var imageArray: [UIImage] = []
        
        do {
            let photoData = try stackManagedObjectContext().fetch(request)
            if photoData.count > 0 {
                for item in photoData {
                    if let image = UIImage(data: item.photo as! Data) {
                        imageArray.append(image)
                    }
                }
            }
        } catch {
            throw error
        }
        
        return imageArray
    }
    
    
    
}
