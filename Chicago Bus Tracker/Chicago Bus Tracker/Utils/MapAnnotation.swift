//
//  MapAnnotation.swift
//  Chicago Bus Tracker
//
//  Created by Honglei Zhou on 3/11/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import Foundation
import MapKit

///
/// Custom object to hold our custom annotation
///
class MapAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let currentStop: Bool?
    let coordinate: CLLocationCoordinate2D
    
    init(currentStop: Bool, title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.currentStop = currentStop
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        super.init()
    }
    
}
