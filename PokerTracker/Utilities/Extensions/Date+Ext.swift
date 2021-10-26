//
//  Date+Ext.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 9/15/21.
//

import Foundation

extension Date {
    func adding(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
}

extension Date {
    func daySubtracting(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
}

extension Date {
    func dayOfWeek(day: Date)-> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            let weekDay = dateFormatter.string(from: day)
            return weekDay
      }
}

extension DateComponents {
    
    var durationInHours: Float {
        let hours: Float = Float(self.hour ?? 0)
        let minuteHours = Float(self.minute ?? 0) * 1/60
        return hours + minuteHours
    }
    
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
