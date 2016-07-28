//
//  ListDestinationsTableViewController.swift
//  AroundZ
//
//  Created by Ow Zhiyin on 27/7/16.
//  Copyright © 2016 Ow Zhiyin. All rights reserved.
//

import UIKit

class ListDestinationsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // 1
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    // 2
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 3
        let cell = tableView.dequeueReusableCellWithIdentifier("listDestinationsTableViewCell", forIndexPath: indexPath)
        
        // 4
        cell.textLabel?.text = "Yay - it's working!"
        
        // 5
        return cell
    }
}
