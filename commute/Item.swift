//
//  Item.swift
//  commute
//
//  Created by Drew Goldstein on 4/8/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
