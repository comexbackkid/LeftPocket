//
//  SimpleEntry.swift
//  LeftPocketWidgetExtension
//
//  Created by Christian Nachtrieb on 8/9/22.
//

import WidgetKit

struct SimpleEntry: TimelineEntry {
    
    let date: Date
    let bankroll: Int
    let recentSessionAmount: Int
    let swiftChartData: [Int]
    let hourlyRate: Int
    let totalSessions: Int
    let currency: String
}
