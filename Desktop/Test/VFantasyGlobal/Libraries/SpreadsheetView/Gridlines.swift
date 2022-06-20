//
//  Gridlines.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/7/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

struct Gridlines {
    var top: GridStyle
    var bottom: GridStyle
    var left: GridStyle
    var right: GridStyle

    public static func all(_ style: GridStyle) -> Gridlines {
        return Gridlines(top: style, bottom: style, left: style, right: style)
    }
}

@available(*, deprecated, renamed: "Gridlines")
typealias Grids = Gridlines

enum GridStyle {
    case `default`
    case none
    case solid(width: CGFloat, color: UIColor)
}

extension GridStyle: Equatable {
    public static func ==(lhs: GridStyle, rhs: GridStyle) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case let (.solid(width1, color1), .solid(width2, color2)):
            return width1 == width2 && color1 == color2
        default:
            return false
        }
    }
}

final class Gridline: CALayer {
    var color: UIColor = .clear {
        didSet {
            backgroundColor = color.cgColor
        }
    }

    override init() {
        super.init()
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func action(forKey event: String) -> CAAction? {
        return nil
    }
}
