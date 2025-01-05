//
//  QuickMetricBox.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 6/29/24.
//

import SwiftUI

struct QuickMetricBox: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let title: String
    let metric: String
    let percentageChange: Double
    
    var body: some View {
        
        VStack (alignment: .leading) {
                        
            VStack (alignment: .leading) {
                
                Text(title)
                    .captionStyle()
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .layoutPriority(1)
                
                HStack (alignment: .lastTextBaseline) {
                    
                    Text("\(metric)")
                        .font(.custom("Asap-Bold", size: 28))
                        .opacity(0.85)
                        .lineLimit(1)
                        .layoutPriority(1)
                    
                    if percentageChange != 0.0 && percentageChange.isFinite {
                        
                        HStack (spacing: 2) {
                            
                            Image(systemName: percentageChange > 0 ? "arrow.up.right" : "arrow.down.right")
                                .font(.custom("Asap-Regular", size: 12))
                                .foregroundStyle(percentageChange > 0 ? Color.lightGreen : .red)
                            
                            Text(abs(percentageChange).asPercent())
                                .font(.custom("Asap-Regular", size: 12))
                                .foregroundStyle(percentageChange > 0 ? Color.lightGreen : .red)
                                .lineLimit(1)
                        }
                    }
                }
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .padding(.vertical, 2)
        .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.5 : 1.0))
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
        .dynamicTypeSize(.small)
    }
}

#Preview {
    QuickMetricBox(title: "Total Hours", metric: "$215.5K", percentageChange: -0.34)
        .frame(width: 275)
}
