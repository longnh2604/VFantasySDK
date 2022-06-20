//
//  Exts+Date.swift
//  VFantasyGlobal
//
//  Created by User on 25/05/2022.
//

import Foundation
import UIKit

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the amount of nanoseconds from another date
    func nanoseconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.nanosecond], from: date, to: self).nanosecond ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offsetDate(from date: Date) -> String {
        let years = self.years(from: date)
        if years > 0 {
            if years == 1 {
                return String(format: "single_year_format".localiz(), years)
            }
            return String(format: "multiple_year_format".localiz(), years)
        }
        
        let months = self.months(from: date)
        if months > 0 {
            if months == 1 {
                return String(format: "single_month_format".localiz(), months)
            }
            return String(format: "multiple_month_format".localiz(), months)
        }
        
        let days = self.days(from: date)
        if days > 0 {
            if days == 1 {
                return String(format: "single_day_format".localiz(), days)
            }
            return String(format: "multiple_day_format".localiz(), days)
        }
        
        let hours = self.hours(from: date)
        if hours > 0 {
            if hours == 1 {
                return String(format: "single_hour_format".localiz(), hours)
            }
            return String(format: "multiple_hour_format".localiz(), hours)
        }
        
        let minutes = self.minutes(from: date)
        if minutes > 0 {
            if minutes == 1 {
                return String(format: "single_minute_format".localiz(), minutes)
            }
            return String(format: "multiple_minute_format".localiz(), minutes)
        }
        
        let seconds = self.seconds(from: date)
        if seconds > 0 {
            if seconds == 1 {
                return String(format: "single_second_format".localiz(), seconds)
            }
            return String(format: "multiple_second_format".localiz(), seconds)
        }
        return ""
    }
    
    func surpass(_ date: Date) -> Bool {
        return self.timeIntervalSince1970 > date.timeIntervalSince1970
    }
    
    func equalOrSurpass(_ date: Date) -> Bool {
        return self.timeIntervalSince1970 >= date.timeIntervalSince1970
    }
    
    func lessThan(_ date: Date) -> Bool {
        return !self.equalOrSurpass(date)
    }
    
    func equalOrLessThan(_ date: Date) -> Bool {
        return self.timeIntervalSince1970 <= date.timeIntervalSince1970
    }
    
    var nextQuarterHour: Date {
        var components = Calendar.current.dateComponents([.year, .month , .day , .hour , .minute], from: self)
        guard let min = components.minute else {
            return self
        }
        if min % 15 != 0 {
            components.minute = min + 15 - (min % 15)
        }
        components.second = 0
        if min > 45 {
            components.hour? += 1
            components.minute = 0
        }
        return Calendar.current.date(from: components) ?? Date()
    }
    
    func toString(_ format:String) -> String? {
        let fromDateFormatter = DateFormatter()
        fromDateFormatter.dateFormat = format
        
        let dateString = fromDateFormatter.string(from: self)
        return dateString
    }
    
    func toString(formatter: String, locale: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter
        dateFormatter.locale = Locale(identifier: locale)
        return dateFormatter.string(from: self)
    }
}
