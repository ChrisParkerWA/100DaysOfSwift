//
//  StringExtension.swift
//  C1WorldFlags
//
//  Created by Chris Parker on 4/3/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import Foundation

extension String {
    func capitaliseFirstLetter() -> String {
        if self.count  < 3 {
            return self.uppercased()
        }
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalisingFirstLetter() {
        self = self.capitaliseFirstLetter()
    }
}
