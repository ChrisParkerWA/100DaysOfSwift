//
//  Capital.swift
//  P16CapCities
//
//  Created by Chris Parker on 13/4/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import MapKit
import UIKit

class Capital: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    
    init( title: String, coordinate: CLLocationCoordinate2D, info: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
    }
    
}
