//
//  DisplayLocationViewController.swift
//  AroundZ
//
//  Created by Ow Zhiyin on 28/7/16.
//  Copyright © 2016 Ow Zhiyin. All rights reserved.
//

import UIKit
import RealmSwift
import MapKit
import CoreLocation
import AddressBookUI


protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}


class DisplayLocationViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    //maps sections
    let locationManager = CLLocationManager()
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    
    @IBOutlet weak var oneLocationMapView: MKMapView!
    
    var location: Location?
    
    //creating the dataSource for the cateogry picker view/maybe can create a class in future
    var categoryTypes = ["Cafes", "Hawkers", "Restaurants", "Shopping", "Meeting Point", "Hotels", "Random"]
    var picker = UIPickerView()
    
    
    
    //creating outlets for the page
    @IBOutlet weak var locationNameTextField: UITextField!
    @IBOutlet weak var locationAddressTextField: UITextField!
    @IBOutlet weak var locationCategoryTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        // Do any additional setup after loading the view.
        
        
        
        let locationSearchTable = storyboard!.instantiateViewControllerWithIdentifier("LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        //configures search bar
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.barTintColor = UIColor.init(red: 255, green: 255, blue: 102, alpha: 1)
        searchBar.placeholder = "Search for places"

        navigationItem.titleView = resultSearchController?.searchBar
        
        //configure appearance
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.oneLocationMapView = oneLocationMapView
        
        locationSearchTable.handleMapSearchDelegate = self
        
        
        //picker view delegate/dataSource
        picker.delegate = self
        picker.dataSource = self
        locationCategoryTextField.inputView = picker
//        self.picker.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.5)
    }
    
    
    
    /////////////Picker View Functions
    // returns the number of 'columns' to display.
  
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // returns the # of rows in each component..
  
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return categoryTypes.count
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        locationCategoryTextField.text = categoryTypes[row]
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryTypes[row]
    }
    ////////////////

    
    /////////Creating the location functions
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)

        // 1
        oneLocationMapView.removeAnnotations(oneLocationMapView.annotations)

        
        if let location = location {
            locationNameTextField.text = location.name
            locationAddressTextField.text = location.address
            locationCategoryTextField.text = location.category
            
            //set the pin when view loads using forward geocoding
            var annotations = [MKPointAnnotation]()
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
                self.oneLocationMapView.addAnnotations(annotations)
            })
            
            
            
        } else {
            locationNameTextField.text = ""
            locationAddressTextField.text = ""
            locationCategoryTextField.text = ""
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let listLocationsTableViewController = segue.destinationViewController as! ListLocationsTableViewController
        if segue.identifier == "Save" {
           
            if let location = location {
                    let newLocation = Location()
                    newLocation.name = locationNameTextField.text ?? ""
                    newLocation.address = locationAddressTextField.text ?? ""
                    newLocation.category = locationCategoryTextField.text ?? ""

                
                    RealmHelper.updateLocation(location, newLocation: newLocation)
                
                } else {
                    let location = Location()
                    location.name = locationNameTextField.text ?? ""
                    location.address = locationAddressTextField.text ?? ""
                    location.category = locationCategoryTextField.text ?? ""
                    location.modificationTime = NSDate()
                
                    RealmHelper.addLocation(location)
                }
            
                listLocationsTableViewController.locations = RealmHelper.retrieveLocations()
            
            }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    
    //letting the map center one of the annotations
    func centerMapOnLocation(location: MKPointAnnotation, regionRadius: Double) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        oneLocationMapView.setRegion(coordinateRegion, animated: true)
    }
    
}


extension DisplayLocationViewController : CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            oneLocationMapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: \(error)")
    }
}


extension DisplayLocationViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        
        
        //setting the fields dynamically
        
        let firstSpace = (placemark.subThoroughfare != nil && placemark.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (placemark.subThoroughfare != nil || placemark.thoroughfare != nil) && (placemark.subAdministrativeArea != nil || placemark.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (placemark.subAdministrativeArea != nil && placemark.administrativeArea != nil) ? " " : ""
        //        let thirdSpace = (placemark != nil && placemark != nil) ? " " : ""
      
        locationNameTextField.text = placemark.name
        
        locationAddressTextField.text = String (
            format:"%@%@%@%@%@%@%@%@%@%@%@",
            // street number
            placemark.subThoroughfare ?? "",
            firstSpace,
            // street name
            placemark.thoroughfare ?? "",
            comma,
            // city
            placemark.locality ?? "",
            secondSpace,
            // state
            placemark.administrativeArea ?? "",
            " ",
            placemark.country ?? "",
            " ",
            placemark.postalCode ?? ""
        )
        // placemark.postalCode
        
        
        // clear existing pins
        oneLocationMapView.removeAnnotations(oneLocationMapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        oneLocationMapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        oneLocationMapView.setRegion(region, animated: true)
    }
}




