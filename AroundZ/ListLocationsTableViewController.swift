//
//  ListDestinationsTableViewController.swift
//  AroundZ
//
//  Created by Ow Zhiyin on 27/7/16.
//  Copyright © 2016 Ow Zhiyin. All rights reserved.
//

import UIKit
import RealmSwift

class ListLocationsTableViewController: UITableViewController {

    var locations: Results<Location>! {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locations = RealmHelper.retrieveLocations()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("listLocationsTableViewCell", forIndexPath: indexPath) as! ListLocationsTableViewCell
        let row = indexPath.row
        
        let location = locations[row]
        
        cell.locationTitleLabel.text = location.name
//        cell.locationTitleLabel.text = "fudge"
        cell.locationModificationTimeLabel.text = location.modificationTime.convertToString()
        cell.locationCategoryLabel.text = location.category
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // 1
        if let identifier = segue.identifier {
            // 2
            if identifier == "displayLocation" {
                // 3
                print("table cell tapped")
                let indexPath = tableView.indexPathForSelectedRow!
                let location = locations[indexPath.row]
                // 3
                let displayLocationViewController = segue.destinationViewController as! DisplayLocationViewController
                // 4
                displayLocationViewController.location = location
                
            } else if identifier == "addLocation" {
                print("add button tapped")
            }
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // 2
        if editingStyle == .Delete {
            RealmHelper.deleteLocation(locations[indexPath.row])
            //2
            locations = RealmHelper.retrieveLocations()
        }
    }
    
        
    @IBAction func unwindToListNotesViewController(segue: UIStoryboardSegue) {
        
        // for now, simply defining the method is sufficient.
        // we'll add code later
        
    }
}
