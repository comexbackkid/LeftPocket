//
//  MainWidgetView.swift
//  LeftPocketWidgetExtension
//
//  Created by Christian Nachtrieb on 8/11/22.
//

import SwiftUI
import WidgetKit
import ActivityKit

struct MainWidgetView: View {
    
    @Environment(\.widgetFamily) var family
    var entry: SimpleEntry
    
    var body: some View {
        
        switch family {
        case .systemSmall: WidgetViewSmall(entry: entry)
        case .systemMedium: WidgetViewMedium(entry: entry)
        default: Text("Unsupported")
            
        }
    }
}
