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
    let chartData: [Point]
    let hourlyRate: Int
    let totalSessions: Int
}
