//
//  ListLocationsTableViewCell.swift
//  AroundZ
//
//  Created by Ow Zhiyin on 28/7/16.
//  Copyright © 2016 Ow Zhiyin. All rights reserved.
//

import UIKit

class ListLocationsTableViewCell: UITableViewCell {
//    var location: Location?{
//        didSet {
//            if let location = location {
//                locationTitleLabel.text = location.name
//                //        cell.locationTitleLabel.text = "fudge"
//                locationModificationTimeLabel.text = location.modificationTime.convertToString()
//                locationCategoryLabel.text = location.category
//            }
//        }
//    }
    @IBOutlet weak var locationTitleLabel: UILabel!
    @IBOutlet weak var locationModificationTimeLabel: UILabel!
    @IBOutlet weak var locationCategoryLabel: UILabel!

}
