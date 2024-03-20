//
//  Provider.swift
//  LeftPocketWidgetExtension
//
//  Created by Christian Nachtrieb on 8/9/22.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(),
                    bankroll: 5200,
                    recentSessionAmount: 150,
                    chartData: MockData.mockDataCoords,
                    hourlyRate: 32,
                    totalSessions: 14)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(),
                                bankroll: 5200,
                                recentSessionAmount: 150,
                                chartData: MockData.mockDataCoords,
                                hourlyRate: 32,
                                totalSessions: 14)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        let bankroll = UserDefaults(suiteName: AppGroup.bankrollSuite)?.integer(forKey: AppGroup.bankrollKey) ?? 0
        let lastSessionAmount = UserDefaults(suiteName: AppGroup.bankrollSuite)?.integer(forKey: AppGroup.lastSessionKey) ?? 0
        let hourlyRate = UserDefaults(suiteName: AppGroup.bankrollSuite)?.integer(forKey: AppGroup.hourlyKey) ?? 0
        let totalSessions = UserDefaults(suiteName: AppGroup.bankrollSuite)?.integer(forKey: AppGroup.totalSessionsKey) ?? 0
        
        guard let chartData = UserDefaults(suiteName: AppGroup.bankrollSuite)?.data(forKey: AppGroup.chartKey) else {
            print("Error loading Chart Data")
            return
        }
        
        var chartPoints: [Point] {
            guard let decodedChartData = try? JSONDecoder().decode([Point].self, from: chartData) else {
                print("Error computing Chart Points")
                return MockData.emptyCoords
            }
            return decodedChartData
        }
        
        let entry = SimpleEntry(date: currentDate,
                                bankroll: bankroll,
                                recentSessionAmount: lastSessionAmount,
                                chartData: chartPoints,
                                hourlyRate: hourlyRate,
                                totalSessions: totalSessions)
        entries.append(entry)
        
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}
