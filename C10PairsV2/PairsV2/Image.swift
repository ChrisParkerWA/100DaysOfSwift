//
//  Card.swift
//  PairsV2
//
//  Created by Chris Parker on 22/6/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit

struct Card: Codable, Equatable {
    var filename: String
    
    init(filename: String) {
        self.filename = filename

    }
}
