//
//  Petition.swift
//  P9Petition
//
//  Created by Chris Parker on 6/3/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import Foundation

struct Petition: Codable {
    var title: String
    var body: String
    var signatureCount: Int
}
