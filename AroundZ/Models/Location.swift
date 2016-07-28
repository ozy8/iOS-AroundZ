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
    var name = ""
    var address = ""
    var category = ""
    var modificationTime = NSDate()
}