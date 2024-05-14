//
//  HealthMetricModel.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 5/9/24.
//

import Foundation
import SwiftUI

struct SleepMetric: Identifiable {
    
    let id = UUID()
    let date: Date
    let value: Double
    
    var startOfDay: Date { date.startOfDay }
 
    static var MockData: [SleepMetric] {
        
        let sleepArray = [
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: 0, to: .now)!, value: 8),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -1, to: .now)!, value: 11),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -2, to: .now)!, value: 6),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -3, to: .now)!, value: 5),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -4, to: .now)!, value: 3),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -5, to: .now)!, value: 5),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -6, to: .now)!, value: 7.5),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -7, to: .now)!, value: 3),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -8, to: .now)!, value: 5.4),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -9, to: .now)!, value: 8),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -10, to: .now)!, value: 5),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -11, to: .now)!, value: 7.7),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -12, to: .now)!, value: 4),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -13, to: .now)!, value: 6),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -14, to: .now)!, value: 8),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -15, to: .now)!, value: 10.8),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -16, to: .now)!, value: 4),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -17, to: .now)!, value: 11),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -18, to: .now)!, value: 9),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -19, to: .now)!, value: 10.2),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -20, to: .now)!, value: 8),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -21, to: .now)!, value: 6),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -22, to: .now)!, value: 4),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -23, to: .now)!, value: 1),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -24, to: .now)!, value: 3),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -25, to: .now)!, value: 9),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -26, to: .now)!, value: 11),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -27, to: .now)!, value: 6.2)
        
        ]
        
        return sleepArray
        
    }
}

// For easier calculations in Sleep Analytics View
extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}

// For easier calculations in Sleep Analytics View
extension [SleepMetric] {
    func sleepHours(on date: Date) -> Double? {
        first { $0.startOfDay == date.startOfDay }?.value
    }
}
