//
//  ListLocationsTableViewCell.swift
//  AroundZ
//
//  Created by Ow Zhiyin on 28/7/16.
//  Copyright © 2016 Ow Zhiyin. All rights reserved.
//

import UIKit

class ListLocationsTableViewCell: UITableViewCell {

    @IBOutlet weak var locationTitleLabel: UILabel!
    @IBOutlet weak var locationModificationTimeLabel: UILabel!
    @IBOutlet weak var locationCategoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
