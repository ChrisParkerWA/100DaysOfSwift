//
//  Structs.swift
//  Extension
//
//  Created by Chris Parker on 30/4/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import Foundation

struct Script: Codable {
    var scriptName: String
    var scriptURL: String
    var scriptContent: String
    
    init(scriptName: String, scriptURL: String, scriptContent: String) {
        self.scriptName = scriptName
        self.scriptURL = scriptURL
        self.scriptContent = scriptContent
    }
}
