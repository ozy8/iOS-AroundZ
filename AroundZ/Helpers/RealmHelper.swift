//
//  RealmHelper.swift
//  AroundZ
//
//  Created by Ow Zhiyin on 28/7/16.
//  Copyright © 2016 Ow Zhiyin. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation
import AddressBookUI

class RealmHelper {
    //static methods will go here
    
    static let realm = try! Realm()
    //static methods will go here
    static func addLocation(location: Location) { //wrapper function. nice way to hide complexities.
        //        let realm = try! Realm()
        try! realm.write() {
            realm.add(location)
        }
    }
    
    static func deleteLocation(location: Location){
        //        let realm = try! Realm()
        try! realm.write() {
            realm.delete(location)
        }
    }
    
    static func updateLocation(locationToBeUpdated: Location, newLocation: Location){
        //        let realm = try! Realm()
        try! realm.write() {
            locationToBeUpdated.name = newLocation.name
            locationToBeUpdated.address = newLocation.address
            locationToBeUpdated.modificationTime = newLocation.modificationTime
            locationToBeUpdated.category = newLocation.category
//            locationToBeUpdated.latitude = newLocation.latitude
//            locationToBeUpdated.longitude = newLocation.longitude
            
            
        }
    }
    
    static func retrieveLocations() -> Results<Location> {
        //        let realm = try! Realm()
        return realm.objects(Location).sorted("modificationTime", ascending: false)
    }
    
}