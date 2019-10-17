//
//  Functions.swift
//  C4Photos
//
//  Created by Chris Parker on 29/3/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import Foundation

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}
