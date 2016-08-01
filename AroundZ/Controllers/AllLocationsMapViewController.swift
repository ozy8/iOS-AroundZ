//
//  AllLocationsMapViewController.swift
//  AroundZ
//
//  Created by Ow Zhiyin on 28/7/16.
//  Copyright © 2016 Ow Zhiyin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AddressBookUI
import RealmSwift

class AllLocationsMapViewController: UIViewController {
    let locationManager = CLLocationManager()
    
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil

    //creating var to recall locaiotns from realm
    var locations: Results<Location>!
    
    @IBOutlet weak var allLocationsMapView: MKMapView!

    override func viewDidLoad() {

        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        let allLocationsSearchTable = storyboard!.instantiateViewControllerWithIdentifier("AllLocationsSearchTable") as! AllLocationsSearchTable
        resultSearchController = UISearchController(searchResultsController: allLocationsSearchTable)
        resultSearchController?.searchResultsUpdater = allLocationsSearchTable
        
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for saved locations"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        allLocationsSearchTable.allLocationsMapView = allLocationsMapView
        
        allLocationsSearchTable.handleMapSearchDelegate = self
        

    }
    
    
    override func viewDidAppear(animated: Bool) {
        allLocationsMapView.removeAnnotations(allLocationsMapView.annotations)

        //creating locations to be used later
        locations = RealmHelper.retrieveLocations()
        
        //creating annotations to populate map with all the POI
        var annotations = [MKPointAnnotation]()
        
        for location in locations {
            
            print(location.address)
            
            var place : CLLocationCoordinate2D?
            
            CLGeocoder().geocodeAddressString(location.address, completionHandler: { (placemarks, error) in
                if error != nil {
                    print(error)
                    return
                }
                if placemarks?.count > 0 {
                    let placemark = placemarks?[0]
                    let location = placemark?.location
                    let coordinate = location?.coordinate
                    print("\nlat: \(coordinate!.latitude), long: \(coordinate!.longitude)")
                    place = coordinate
                }
                print(place)
                
                
                let name = location.name
                let annotation = MKPointAnnotation()
                annotation.coordinate = place!
                print(annotation.coordinate)
                annotation.title = "\(name)"
                annotation.subtitle = location.category
                annotations.append(annotation)
                
                
                //calling the func created below
                self.centerMapOnLocation(annotations[0], regionRadius: 1000.0)
                
                //add annotations to mapView
                self.allLocationsMapView.addAnnotations(annotations)
            })
        }

    }
    
 
    //letting the map center one of the annotations
    func centerMapOnLocation(location: MKPointAnnotation, regionRadius: Double) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        allLocationsMapView.setRegion(coordinateRegion, animated: true)
    }
}

extension AllLocationsMapViewController : CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            allLocationsMapView.setRegion(region, animated: true)
            
            print("location:: \(location)")
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: \(error)")
    }
}

extension AllLocationsMapViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        allLocationsMapView.removeAnnotations(allLocationsMapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        allLocationsMapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        allLocationsMapView.setRegion(region, animated: true)
    }
}


