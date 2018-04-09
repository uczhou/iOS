//
//  StopMapTableViewCell.swift
//  Chicago Bus Tracker
//
//  Created by Honglei Zhou on 3/10/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import UIKit

/// - StopMapTableViewCell: Used in RouteMapStopViewController
class StopMapTableViewCell: UITableViewCell {

    @IBOutlet weak var routeNumber: UILabel!
    @IBOutlet weak var stopName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
