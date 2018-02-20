//
//  StockTableViewCell.swift
//  News
//
//  Created by Honglei Zhou on 2/2/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import UIKit

class StockTableViewCell: UITableViewCell {

    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var curPriceLabel: UILabel!
    @IBOutlet weak var opPriceLabel: UILabel!
    @IBOutlet weak var wkHighLabel: UILabel!
    @IBOutlet weak var wkLowLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
