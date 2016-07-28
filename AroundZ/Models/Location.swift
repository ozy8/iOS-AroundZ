//
//  Location.swift
//  AroundZ
//
//  Created by Ow Zhiyin on 28/7/16.
//  Copyright © 2016 Ow Zhiyin. All rights reserved.
//

import Foundation
import RealmSwift

class Location: Object  {
    dynamic var name = ""
    dynamic var address = ""
    dynamic var category = ""
    dynamic var modificationTime = NSDate()
}