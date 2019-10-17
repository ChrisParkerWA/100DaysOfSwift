//
//  StringExtension.swift
//  C2ShoppingList
//
//  Created by Chris Parker on 6/3/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import Foundation

extension String {
    func capitaliseFirstLetter() -> String {
        if self.count <= 2 { return self.uppercased() }
        return prefix(1).uppercased() + self.dropFirst()
    }
    
    mutating func capitalisingFirstLetter() {
        self = self.capitaliseFirstLetter()
    }
}
