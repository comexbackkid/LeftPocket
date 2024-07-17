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
    
    var body: some View {
        
        HStack {
            VStack (alignment: .leading) {
                Text(title)
                    .captionStyle()
                    .foregroundStyle(.secondary)
                
                Text("\(metric)")
                    .font(.custom("Asap-Bold", size: 28, relativeTo: .title2))
                    .opacity(0.85)
                    .lineLimit(1)
            }
            
            Spacer()
            
        }
        .padding(20)
        .frame(width: 157)
        .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.35 : 1.0))
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
    }
}

#Preview {
    QuickMetricBox(title: "Total Hours", metric: "$215.5K")
}
