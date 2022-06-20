//
//  Exts+Numbers.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit

extension Int {
    var roundedWithAbbreviations: String {
        var number = Double(self)
        let signMinus = number < 0 ? "-" : ""
        number *= number < 0 ? -1 : 1
        let thousand = number / 1000
        let million = number / 1000000
        if million >= 1.0 {
            return "\(signMinus)\(round(million*10)/10)" + String("mio_suffix").localiz()
        }
        else if thousand >= 1.0 {
            return "\(signMinus)\(round(thousand*10)/10)k"
        }
        else {
            return "\(signMinus)\(Int(number))"
        }
    }
    
    var priceDisplay: String {
        return "\(self.roundedWithAbbreviations.replacingOccurrences(of: ".0", with: ""))"
    }
    
    func toPoints() -> String {
        let stringValue = String(self)
        if self != 1 {
            return stringValue + " " + String("points".localiz())
        }
        return stringValue + " " + String("point".localiz())
    }
    
    func secondsToHoursMinutesSeconds () -> (Int, Int, Int) {
        let seconds = self
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}

extension Double {
    func roundToInt() -> Int {
        return Int(Darwin.round(self))
    }
    
    var priceDisplay: String {
        return "\(self.roundedWithAbbreviations.replacingOccurrences(of: ".0", with: ""))"
    }
    
    var priceNoUnitDisplay: String {
        return "\(self.roundedWithAbbreviations.replacingOccurrences(of: ".0", with: ""))"
    }
    
    var roundedWithAbbreviations: String {
        var number = self
        let signMinus = number < 0 ? "-" : ""
        number *= number < 0 ? -1 : 1
        let thousand = number / 1000.0
        let million = number / 1000000.0
        if million >= 1.0 {
            let value = Darwin.round(million*10)/10
            return "\(signMinus)\(value)" + String("mio_suffix".localiz())
        }
        else if thousand >= 1.0 {
            let value = Darwin.round(thousand*10)/10
            return "\(signMinus)\(value)K"
        }
        else {
            return "\(signMinus)\(Int(number))"
        }
    }
}
