//
//  TicTac.swift
//  Game
//
//  Created by Honglei Zhou on 2/8/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import UIKit

class TicTac: UIImageView {
    let width = 114
    let height = 114
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        doubleSize()
        oneSize()
    }
    
    
    func halfSize() {
        self.frame.size = CGSize(width: self.width/2, height: self.height/2)
    }
    
    func doubleSize() {
        self.frame.size = CGSize(width: self.width * 2, height: self.height * 2)
    }
    
    func oneSize() {
        self.frame.size = CGSize(width: self.width, height: self.height)
    }
    
}
