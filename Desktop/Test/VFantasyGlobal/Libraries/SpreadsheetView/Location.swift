//
//  Location.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 4/19/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

struct Location: Hashable {
    let row: Int
    let column: Int

    init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }

    init(indexPath: IndexPath) {
        self.init(row: indexPath.row, column: indexPath.column)
    }

    var hashValue: Int {
        return 32768 * row + column
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(32768 * row + column)
    }

    public static func ==(lhs: Location, rhs: Location) -> Bool {
        return lhs.row == rhs.row && lhs.column == rhs.column
    }
}
