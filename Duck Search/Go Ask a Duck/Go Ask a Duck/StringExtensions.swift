//
//  StrinExtensions.swift
//  Go Ask a Duck
//
//  Created by Honglei Zhou on 2/18/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import Foundation

extension String {
    
    func contains(_ s: String) -> Bool {
        return (self.range(of: s) != nil) ? true : false
    }
    
}
