//
//  WidgetChart.swift
//  LeftPocketWidgetExtension
//
//  Created by Christian Nachtrieb on 8/11/22.
//

import SwiftUI
import WidgetKit

struct WidgetChart: View {
    
    @Environment(\.colorScheme) var colorScheme
    let data: [Point]
    
    var body: some View {
        
        chartBody
    
    }
    
    private var chartBody: some View {
        
        let pathProvider = LineChartProvider(data: data, lineRadius: 0.5)
        
        return GeometryReader { geometry in
            ZStack {
                
                // Background
                pathProvider.closedPath(for: geometry)
                    .fill(
                        LinearGradient(gradient: Gradient(colors: [.white.opacity(colorScheme == .dark ? 0.0 : 0.25), Color("lightBlue").opacity(0.5)]),
                                       startPoint: .bottom,
                                       endPoint: .top)
                    )
                
                // Line
                pathProvider.path(for: geometry)
                    .stroke(
                        LinearGradient(gradient: Gradient(colors: [.chartBase, .chartAccent]),
                                       startPoint: .leading,
                                       endPoint: .trailing),
                        style: StrokeStyle(lineWidth: 3)
                    )
            }
        }
    }
}

struct WidgetChart_Previews: PreviewProvider {
    static var previews: some View {
        WidgetChart(data: MockData.mockDataCoords)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

struct MockData {
    
    static let mockDataCoords: [Point] = [
        .init(x: 0, y: 0),
        .init(x: 1, y: -2),
        .init(x: 2, y: 10),
        .init(x: 3, y: 6),
        .init(x: 4, y: 9),
        .init(x: 5, y: 12),
        .init(x: 6, y: 14),
        .init(x: 7, y: 11),
    ]
    
    static let emptyCoords: [Point] = [
        .init(x: 0, y: 0),
        .init(x: 1, y: 0)
    ]
}
