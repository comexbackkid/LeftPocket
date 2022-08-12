//
//  Provider.swift
//  LeftPocketWidgetExtension
//
//  Created by Christian Nachtrieb on 8/9/22.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    let appGroup = AppGroup()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(),
                    bankroll: 5200,
                    recentSessionAmount: 150,
                    chartData: FakeData.mockDataCoords,
                    hourlyRate: 32,
                    totalSessions: 14)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(),
                                bankroll: 5200,
                                recentSessionAmount: 150,
                                chartData: FakeData.mockDataCoords,
                                hourlyRate: 32,
                                totalSessions: 14)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        let bankroll = UserDefaults(suiteName: appGroup.bankrollSuite)?.integer(forKey: appGroup.bankrollKey)
        let lastSessionAmount = UserDefaults(suiteName: appGroup.bankrollSuite)?.integer(forKey: appGroup.lastSessionKey) ?? 0
        let hourlyRate = UserDefaults(suiteName: appGroup.bankrollSuite)?.integer(forKey: appGroup.hourlyKey) ?? 0
        let totalSessions = UserDefaults(suiteName: appGroup.bankrollSuite)?.integer(forKey: appGroup.totalSessionsKey) ?? 0
        
        guard let chartData = UserDefaults(suiteName: appGroup.bankrollSuite)?.data(forKey: appGroup.chartKey) else {
            print("Error loading Chart Data")
            return
        }
        
        var chartPoints: [Point] {
            
            guard let decodedChartData = try? JSONDecoder().decode([Point].self, from: chartData) else {
                print("Error computing Chart Points")
                return FakeData.mockDataCoords
            }
            return decodedChartData
        }
        
        if bankroll != 0 {
            entries.append(SimpleEntry(date: currentDate,
                                       bankroll: bankroll ?? 0,
                                       recentSessionAmount: lastSessionAmount,
                                       chartData: chartPoints,
                                       hourlyRate: hourlyRate,
                                       totalSessions: totalSessions))
            
        } else {
            entries.append(SimpleEntry(date: currentDate,
                                       bankroll: 0,
                                       recentSessionAmount: 0,
                                       chartData: chartPoints,
                                       hourlyRate: 0,
                                       totalSessions: 0))
        }
        
//        var entries = [SimpleEntry(date: currentDate, bankroll: bankroll as! Int)]
        
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = SimpleEntry(date: entryDate, bankroll: 6000)
//            entries.append(entry)
//        }

        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}
