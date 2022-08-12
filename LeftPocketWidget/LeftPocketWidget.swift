//
//  LeftPocketWidget.swift
//  LeftPocketWidget
//
//  Created by Christian Nachtrieb on 8/9/22.
//

import WidgetKit
import SwiftUI

@main
struct LeftPocketWidget: Widget {
    
    let kind: String = "LeftPocketWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MainWidgetView(entry: entry)
        }
        .configurationDisplayName("Bankroll Management")
        .description("A snapshot of your poker bankroll.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct LeftPocketWidget_Previews: PreviewProvider {
    static var previews: some View {
        WidgetViewSmall(entry: SimpleEntry(date: Date(), bankroll: 6000, recentSessionAmount: 150, chartData: FakeData.mockDataCoords, hourlyRate: 32, totalSessions: 14))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
