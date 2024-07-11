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
                    swiftChartData: [0,350,220,457,900,719,333,1211,1400,1765,1500,1828,1721],
                    hourlyRate: 32,
                    totalSessions: 14,
                    currency: "USD")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(),
                                bankroll: 5200,
                                recentSessionAmount: 150,
                                swiftChartData: [0,350,220,457,900,719,333,1211,1400,1765,1500,1828,1721],
                                hourlyRate: 32,
                                totalSessions: 14,
                                currency: "USD")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        let bankroll = UserDefaults(suiteName: AppGroup.bankrollSuite)?.integer(forKey: AppGroup.bankrollKey) ?? 0
        let lastSessionAmount = UserDefaults(suiteName: AppGroup.bankrollSuite)?.integer(forKey: AppGroup.lastSessionKey) ?? 0
        let hourlyRate = UserDefaults(suiteName: AppGroup.bankrollSuite)?.integer(forKey: AppGroup.hourlyKey) ?? 0
        let totalSessions = UserDefaults(suiteName: AppGroup.bankrollSuite)?.integer(forKey: AppGroup.totalSessionsKey) ?? 0
        let currency = UserDefaults(suiteName: AppGroup.bankrollSuite)?.string(forKey: AppGroup.currencyKey) ?? "USD"
        
        guard let swiftChartData = UserDefaults(suiteName: AppGroup.bankrollSuite)?.data(forKey: AppGroup.swiftChartKey) else {
            print("Error loading Chart Data")
            return
        }
        
        var swiftChartPoints: [Int] {
            guard let decodedSwiftChartData = try? JSONDecoder().decode([Int].self, from: swiftChartData) else {
                print("Error computing Chart Points")
                return []
            }
            return decodedSwiftChartData
        }
        
        let entry = SimpleEntry(date: currentDate,
                                bankroll: bankroll,
                                recentSessionAmount: lastSessionAmount,
                                swiftChartData: swiftChartPoints,
                                hourlyRate: hourlyRate,
                                totalSessions: totalSessions,
                                currency: currency)
        entries.append(entry)
        
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}
