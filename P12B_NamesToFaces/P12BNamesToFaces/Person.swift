//
//  Person.swift
//  P12BNamesToFaces
//
//  Created by Chris Parker on 16/3/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit

class Person: NSObject, Codable {
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image        
    }
}
