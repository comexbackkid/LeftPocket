//
//  WidgetView.swift
//  LeftPocketWidgetExtension
//
//  Created by Christian Nachtrieb on 8/9/22.
//

import SwiftUI
import WidgetKit

struct WidgetView : View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var entry: SimpleEntry

    var body: some View {
        
        ZStack (alignment: .bottom) {
            
            backgroundGradient
            
            logo
            
            numbers
            
        }
    }
    
    var backgroundGradient: some View {
        Color("WidgetBackground")
            .overlay(LinearGradient(colors: [Color("WidgetBackround"), .black.opacity(colorScheme == .dark ? 0.6 : 0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing))
    }
    
    var logo: some View {
        VStack {
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "suit.club.fill")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .foregroundColor(.brandPrimary)
                                .frame(width: 32, height: 32, alignment: .center)
                    )
                }
                
            }
            .padding(20)
            Spacer()
        }
    }
    
    var numbers: some View {
        
        VStack {
            HStack {
                Text("Total Bankroll")
                    .foregroundColor(.secondary)
                    .font(.caption)
                Spacer()
            }
            HStack {
                Text("$" + "\(entry.bankroll)")
                    .foregroundColor(.widgetForegroundText)
                    .font(.system(.title, design: .rounded))
                
                Spacer()
            }
            
            HStack {
                Image(systemName: "arrowtriangle.up.fill")
                    .foregroundColor(.green)
                
                Text("$" + "\(entry.recentSessionAmount)")
                    .foregroundColor(.green)
                    .font(.subheadline)
                    .bold()
                
                Spacer()
            }
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 12)
    }
}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetView(entry: SimpleEntry(date: Date(), bankroll: 6351, recentSessionAmount: 150))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
