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
    var dayNoYear: String { date.formatted(.dateTime.day().month()) }
 
    static var MockData: [SleepMetric] {
        
        let sleepArray = [
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -1, to: .now)!, value: 7.3),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -2, to: .now)!, value: 6),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -3, to: .now)!, value: 5.9),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -4, to: .now)!, value: 5.2),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -5, to: .now)!, value: 5),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -6, to: .now)!, value: 7.5),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -7, to: .now)!, value: 5),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -8, to: .now)!, value: 5.4),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -9, to: .now)!, value: 8),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -10, to: .now)!, value: 5.2),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -11, to: .now)!, value: 7.7),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -12, to: .now)!, value: 4.7),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -13, to: .now)!, value: 6),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -14, to: .now)!, value: 8),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -15, to: .now)!, value: 8.8),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -16, to: .now)!, value: 4),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -17, to: .now)!, value: 6.4),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -18, to: .now)!, value: 9),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -19, to: .now)!, value: 9.2),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -20, to: .now)!, value: 8),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -21, to: .now)!, value: 6),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -22, to: .now)!, value: 4),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -23, to: .now)!, value: 6.3),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -24, to: .now)!, value: 5.3),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -25, to: .now)!, value: 9),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -26, to: .now)!, value: 7),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -27, to: .now)!, value: 6.2),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -28, to: .now)!, value: 8.0),
        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -29, to: .now)!, value: 8.4),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -30, to: .now)!, value: 8.2),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -31, to: .now)!, value: 7.5),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -32, to: .now)!, value: 8.0),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -33, to: .now)!, value: 7.2),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -34, to: .now)!, value: 5.6),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -35, to: .now)!, value: 6.1),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -36, to: .now)!, value: 6.9),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -37, to: .now)!, value: 7.9),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -38, to: .now)!, value: 6.7),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -39, to: .now)!, value: 8.0),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -40, to: .now)!, value: 7.8),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -41, to: .now)!, value: 7.0),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -42, to: .now)!, value: 6.7),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -43, to: .now)!, value: 5.6),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -44, to: .now)!, value: 6.0),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -45, to: .now)!, value: 6.2),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -46, to: .now)!, value: 8.0),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -47, to: .now)!, value: 6.7),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -48, to: .now)!, value: 5.7),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -49, to: .now)!, value: 6.3),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -50, to: .now)!, value: 4.8),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -51, to: .now)!, value: 8.3),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -52, to: .now)!, value: 7.3),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -53, to: .now)!, value: 7.1),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -54, to: .now)!, value: 6.6),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -55, to: .now)!, value: 6.7),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -56, to: .now)!, value: 8.1),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -57, to: .now)!, value: 8.0),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -58, to: .now)!, value: 7.5),
//        SleepMetric(date: Calendar.current.date(byAdding: .day, value: -59, to: .now)!, value: 6.8),
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
