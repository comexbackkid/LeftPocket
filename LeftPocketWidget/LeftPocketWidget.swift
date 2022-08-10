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
            WidgetView(entry: entry)
        }
        .configurationDisplayName("Left Pocket")
        .description("Keep a snapshot of your bankroll front & center.")
        .supportedFamilies([.systemSmall])
    }
}

struct LeftPocketWidget_Previews: PreviewProvider {
    static var previews: some View {
        WidgetView(entry: SimpleEntry(date: Date(), bankroll: 6000, recentSessionAmount: 150))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
