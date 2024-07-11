//
//  LeftPocketWidget.swift
//  LeftPocketWidget
//
//  Created by Christian Nachtrieb on 8/9/22.
//

import WidgetKit
import SwiftUI
import Charts

struct LeftPocketWidget: Widget {
    
    let kind: String = "LeftPocketWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MainWidgetView(entry: entry)
        }
        .configurationDisplayName("Bankroll Management")
        .description("A snapshot of your poker bankroll.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}

// Fixes background padding issues in iOS 17
extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}

struct LeftPocketWidget_Previews: PreviewProvider {
    static var previews: some View {
        WidgetViewSmall(entry: SimpleEntry(date: Date(), bankroll: 6000, recentSessionAmount: 150, swiftChartData: [0,350,220,457,900,869,700,1211,1400,1765,1500,1388], hourlyRate: 32, totalSessions: 14, currency: "EUR"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
