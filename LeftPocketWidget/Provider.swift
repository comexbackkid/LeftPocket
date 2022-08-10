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
                    bankroll: 6000,
                    recentSessionAmount: 150)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(),
                                bankroll: 6000,
                                recentSessionAmount: 150)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        
        var entries: [SimpleEntry] = []
        let bankroll = UserDefaults(suiteName: "group.bankrollData")!.integer(forKey: "bankrollTotal")
        let lastSessionAmount = UserDefaults(suiteName: "group.bankrollData")!.integer(forKey: "lastSessionAmount")
        let currentDate = Date()
        
        if bankroll != 0 {
            entries.append(SimpleEntry(date: currentDate,
                                       bankroll: bankroll,
                                       recentSessionAmount: lastSessionAmount))
            
        } else {
            entries.append(SimpleEntry(date: currentDate,
                                       bankroll: 69,
                                       recentSessionAmount: 150))
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


