//
//  Exts+TimeInterval.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit

extension TimeInterval {
    private var milliseconds: Int {
        return Int((truncatingRemainder(dividingBy: 1)) * 1000)
    }
    
    private var seconds: Int {
        return Int(self) % 60
    }
    
    private var minutes: Int {
        return (Int(self) / 60 ) % 60
    }
    
    private var hours: Int {
        return Int(self) / 3600
    }
    
    var stringTime: String {
        var time = ""
        if hours != 0 {
            time = time + String(format: "hour_format".localiz(), hours)
        }
        if minutes != 0 {
            time = time + String(format: "minutes_format".localiz(), minutes)
        }
        
        if seconds != 0 {
            time = time + String(format: "second_format".localiz(), seconds)
        }
        return time
    }
    
    func timeIntervalAsString() -> String {
        var asInt   = NSInteger(self)
        let ago = (asInt < 0)
        if (ago) {
            asInt = -asInt
        }
        let m = (asInt / 60) % 60
        let h = ((asInt / 3600))%24
        let d = (asInt / 86400)
        
        var value = ""
        if d > 0 {
            value = String(format: "day_format".localiz(), d)
            return value
        }
        if h > 0 || m > 0{
            if h > 0 {
                value = value + String(format: "hour_format".localiz(), hours)
            }
            if m > 0 {
                value = value + ", " + String(format: "minutes_format".localiz(), minutes)
            }
            return value
        }
        if (ago) {
            value += "ago_suffix".localiz()
        }
        return value
    }
}

