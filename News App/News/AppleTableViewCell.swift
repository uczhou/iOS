//
//  NewsTableViewCell.swift
//  News
//
//  Created by Honglei Zhou on 2/1/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import UIKit

class AppleTableViewCell: UITableViewCell {
    
    // Mark: Properties
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsSource: UILabel!
    @IBOutlet weak var newsDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
