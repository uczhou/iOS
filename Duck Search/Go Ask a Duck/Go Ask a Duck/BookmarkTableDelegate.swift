//
//  BookmarkTableDelegate.swift
//  Go Ask a Duck
//
//  Created by Honglei Zhou on 2/18/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import Foundation

protocol BookmarkTableDelegate: class {
    /// Pass a string representing a URL back to the a class that conforms to the
    /// protoocol
    func passCellContent(_ url: String) -> Void
    
}
