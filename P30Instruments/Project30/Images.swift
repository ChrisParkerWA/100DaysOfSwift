//
//  Images.swift
//  Project30
//
//  Created by Chris Parker on 20/6/19.
//  Copyright © 2019 Hudzilla. All rights reserved.
//

import UIKit

class Images: NSObject {
    var filename: String
    var imageName: String
    
    init(filename: String, imageName: String) {
        self.filename = filename
        self.imageName = imageName
    }
}
