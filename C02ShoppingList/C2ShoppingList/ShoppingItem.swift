//
//  ShoppingItem.swift
//  C2ShoppingList
//
//  Created by Chris Parker on 4/6/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import Foundation

class ShoppingItem: Codable {
    var item: String
    var purchased: Bool
    
    init(item: String, purchased: Bool){
        self.item = item
        self.purchased = purchased
    }
}
