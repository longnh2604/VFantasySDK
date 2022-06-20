//
//  Exts+String.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
    
    var floatValue: CGFloat {
        return CGFloat((self as NSString).floatValue)
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
    func toString(fromFormat:String, _ toFormat:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
        
        var formattedDateString = ""
        
        if let date = dateFormatter.date(from:self) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            let finalDate = calendar.date(from:components)
            
            let toDateFormatter = DateFormatter()
            toDateFormatter.dateFormat = toFormat
            toDateFormatter.amSymbol = "am".localiz()
            toDateFormatter.pmSymbol = "pm".localiz()
            formattedDateString = toDateFormatter.string(from: finalDate!)
        }
        return formattedDateString
    }
    
    func toDate(fromFormat:String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
        if let date = dateFormatter.date(from:self) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            let finalDate = calendar.date(from:components)
            return finalDate
        }
        return nil
    }
    
    var timeToDate: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat.kyyyyMMdd_1
        return dateFormatter.date(from: self)
    }
    
    func durationTime(_ fromFormat:String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
        if let date = dateFormatter.date(from:self) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            let finalDate = calendar.date(from:components)
            let timeInterval = finalDate?.timeIntervalSinceNow
            let time = timeInterval?.timeIntervalAsString()
            return time
        }
        return nil
    }
    
    func using12hClockFormat() -> Bool {
        
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        let dateString = formatter.string(from: Date())
        let amRange = dateString.range(of: formatter.amSymbol)
        let pmRange = dateString.range(of: formatter.pmSymbol)
        
        return !(pmRange == nil && amRange == nil)
    }
    
    func validDisplayDate() -> String {
        return self.toString(fromFormat: DateFormat.kyyyyMMdd_hhmmss, DateFormat.kyyyyMMdd_1)
    }
    
    func validDisplayTime() -> String {
        if self.isEmpty { return self }
        return self.toString(fromFormat: DateFormat.kyyyyMMdd_hhmmss, DateFormat.kyyyyMMdd_hhmm)
    }
    
    func hourMinute() -> String? {
        if let date = self.toDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = DateFormat.kyyyyMMdd_hhmm
            let currentDateString: String = dateFormatter.string(from: date)
            let hourMinute = currentDateString.split(separator: " ")[1]
            
            return String(hourMinute)
        }
        return nil
    }
    
    var toDate: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat.kyyyyMMdd_hhmmss
        return dateFormatter.date(from: self)
    }
    
    func getSumaryName() -> String {
        let value = self.trimmingCharacters(in: .whitespaces)
        let comps = value.components(separatedBy: " ")
        if comps.count >= 2 {
            var results: [String] = []
            for index in 0..<comps.count {
                let valueStr = comps[index]
                if valueStr.isEmpty {
                    continue
                }
                if index == comps.count - 1 {
                    results.append(valueStr)
                } else {
                    results.append(valueStr.substring(to: 1))
                }
            }
            if results.count >= 2 {
                return results.joined(separator: ". ")
            }
            return value
        }
        return value
    }
    
    func upperFirstCharacter() -> String {
        if self.isEmpty {
            return self
        }
        let first = self.substring(to: 1)
        let others = self.substring(from: 1)
        return "\(first.uppercased())\(others.lowercased())"
    }
    
    func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
    
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        let range: Range<Index> = start..<end
        return String(self[range])
    }
    
    func toDateComponents(_ dateFormat: String) -> DateComponents {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.date(from: self)
        let calendar = Calendar.current
        return calendar.dateComponents([.year, .month, .day, .hour], from: date!)
    }
    
    func isValidEmail() -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailMat = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailMat.evaluate(with: self)
    }
}
