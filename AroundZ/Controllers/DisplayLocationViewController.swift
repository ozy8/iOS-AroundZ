//
//  DisplayLocationViewController.swift
//  AroundZ
//
//  Created by Ow Zhiyin on 28/7/16.
//  Copyright © 2016 Ow Zhiyin. All rights reserved.
//

import UIKit
import RealmSwift



class DisplayLocationViewController: UIViewController {
    
    var location: Location?
    
    @IBOutlet weak var locationNameTextField: UITextField!
    @IBOutlet weak var locationAddressTextField: UITextField!
    @IBOutlet weak var locationCategoryTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

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
                    location.category = locationCategoryTextField.text ?? ""
//                    newLocation.modificationTime = NSDate()
              
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


}
