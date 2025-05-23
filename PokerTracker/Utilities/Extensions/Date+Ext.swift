//
//  Date+Ext.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 9/15/21.
//

import Foundation
import SwiftUI

extension Date {
    
    // Displays date like "Oct 12, 2021."
    func dateStyle() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: self)
    }
    
    // Returns just the day of the week from a Date in String format
    func getWeekday() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE" // returns full weekday names, e.g., "Monday"
        return dateFormatter.string(from: self)
    }
    
    // Returns just the month from a Date in String format
    func monthOfYear(month: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let month = dateFormatter.string(from: month)
        return month
    }
    
    // Retrieves just the year from a Date object. Using lowercase helped with date filtering
    func getYear() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let year = dateFormatter.string(from: self)
        return year
    }
    
    func getYearShortHand() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY"
        let year = dateFormatter.string(from: self)
        return year
    }
    
    // Modifier to get month from a Date with option to abbreviate the month
    func getMonth(abbreviated: Bool = false) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"  // Start by getting the full month name
        let fullMonthName = dateFormatter.string(from: self)
        
        if fullMonthName.count > 4 {
            dateFormatter.dateFormat = abbreviated ? "MMM" : "MMMM"  // Change to abbreviation if more than 4 letters
            return dateFormatter.string(from: self)
        } else {
            return fullMonthName
        }
    }
    
    // Using this as a default starting point when user enters a new Session
    func modifyDays(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
    
    // Used in our dummy data for preview purposes only
    func modifyTime(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
    
    // Used in charting with Swift Charts
    static func from(year: Int, month: Int, day: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: day)
        return Calendar.current.date(from: components)!
    }
}

// Used in charting with Swift Charts
extension Calendar {
    
    func startOfMonth(for date: Date) -> Date {
        let components = self.dateComponents([.year, .month], from: date)
        return self.date(from: components)!
    }
}

extension DateComponents {
    
    var durationInHours: Float {
        let hours: Float = Float(self.hour ?? 0)
        let minuteHours = Float(self.minute ?? 0) * 1/60
        return hours + minuteHours
    }
    
    // Formatted for our DetailView
    var formattedDuration: String {
        let hours = self.hour ?? 0
        let minutes = self.minute ?? 0
        
        if minutes < 10 {
            return "\(hours):0\(minutes)"
        } else {
            return "\(hours):\(minutes)"
        }
    }
    
    func durationShortHand() -> String {
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.unitsStyle = .abbreviated
        let totalHours = dateFormatter.string(from: self)!
        return totalHours
    }
}


