//
//  Photo.swift
//  C4Photos
//
//  Created by Chris Parker on 25/3/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit

class Photo: NSObject, Codable {
    var image: String
    var caption: String
    
    init(image: String, caption: String) {
        self.image = image
        self.caption = caption
    }
}
