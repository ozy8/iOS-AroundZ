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
    var categoryTypes = ["Cafes", "Restaurants", "Shopping", "Meeting Point", "Hotels", "Random"]
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
        
        if let location = location {
            locationNameTextField.text = location.name
            locationAddressTextField.text = location.address
            locationCategoryTextField.text = location.category
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
                
                    print(newLocation.category)
                    
                    RealmHelper.updateLocation(location, newLocation: newLocation)
                
                print(RealmHelper.retrieveLocations())
                
                } else {
                    let location = Location()
                    location.name = locationNameTextField.text ?? ""
                    location.address = locationAddressTextField.text ?? ""
                    location.category = locationCategoryTextField.text ?? ""
                    location.modificationTime = NSDate()
                
                print(location.name)
                print(location.category)
                    RealmHelper.addLocation(location)
                }
            
                listLocationsTableViewController.locations = RealmHelper.retrieveLocations()
            
            }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    
    //show directions in Maps
    func getDirections(){
        if let selectedPin = selectedPin {
            let oneLocationMapView = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            oneLocationMapView.openInMapsWithLaunchOptions(launchOptions)
        }
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
        locationNameTextField.text = placemark.name
        locationAddressTextField.text = placemark.postalCode
        
        
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


extension DisplayLocationViewController : MKMapViewDelegate {
    func oneLocationMapView(oneLocationMapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = oneLocationMapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orangeColor()
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPointZero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), forState: .Normal)
        button.addTarget(self, action: #selector(DisplayLocationViewController.getDirections), forControlEvents: .TouchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
}


