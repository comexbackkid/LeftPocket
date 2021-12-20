//
//  Date+Ext.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 9/15/21.
//

import Foundation

extension Date {
    
    // Displays date like "Oct 12, 2021."
    func dateStyle() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: self)
    }
    
    // Returns just the day of the week from a Date in String format
    func dayOfWeek(day: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let weekDay = dateFormatter.string(from: day)
        return weekDay
    }
    
    // Returns just the month from a Date in String format
    func monthOfYear(month: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let month = dateFormatter.string(from: month)
        return month
    }
    
    // Retrieves just the year from a Date object
    func getYear() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY"
        let year = dateFormatter.string(from: self)
        return year
    }
    
    // Modifier to get month from a Date Object
    func getMonth() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let month = dateFormatter.string(from: self)
        return month
    }
    
    // Using this as a default starting point when user enters a new Session
    func modifyDays(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
    
    // Used in our dummy data for preview purposes only
    func modifyTime(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
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
    
    func totalHours(duration: DateComponents) -> String {
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.unitsStyle = .full
        let totalHours = dateFormatter.string(from: duration)!
        return totalHours
    }
}
