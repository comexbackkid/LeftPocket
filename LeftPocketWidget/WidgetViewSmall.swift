//
//  WidgetViewSmall.swift
//  LeftPocketWidgetExtension
//
//  Created by Christian Nachtrieb on 8/9/22.
//

import SwiftUI
import WidgetKit

struct WidgetViewSmall : View {
    
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
            .overlay(LinearGradient(colors: [Color("WidgetBackround"), .black.opacity(colorScheme == .dark ? 0.7 : 0.1)],
                                    startPoint: .bottomTrailing,
                                    endPoint: .topLeading))
    }
    
    var logo: some View {
        VStack {
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "suit.club.fill")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .foregroundColor(.brandPrimary)
                                .frame(width: 34, height: 34, alignment: .center)
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
                Text("My Bankroll")
                    .foregroundColor(.secondary)
                    .font(.caption)
                Spacer()
            }
            HStack {
                Text(entry.bankroll.accountingStyle())
                    .foregroundColor(.widgetForegroundText)
                    .font(.system(.title, design: .rounded))
                
                Spacer()
            }
            
            HStack {
                Image(systemName: "arrowtriangle.up.fill")
                    .resizable()
                    .frame(width: 11, height: 11)
                    .foregroundColor(entry.recentSessionAmount > 0 ? .green : entry.recentSessionAmount < 0 ? .red : Color(.systemGray))
                    .rotationEffect(entry.recentSessionAmount >= 0 ? .degrees(0) : .degrees(180))
                
                Text(entry.recentSessionAmount.accountingStyle())
                    .foregroundColor(entry.recentSessionAmount > 0 ? .green : entry.recentSessionAmount < 0 ? .red : Color(.systemGray))
                    .font(.subheadline)
                    .bold()
                
                Spacer()
            }
            .padding(.top, -18)
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }
}

extension Int {
    
    public func accountingStyle() -> String {
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = .currency
        numFormatter.maximumFractionDigits = 0
        numFormatter.locale = .current
        numFormatter.currencySymbol = "$"
        return numFormatter.string(from: NSNumber(value: self)) ?? "0"
    }
}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetViewSmall(entry: SimpleEntry(date: Date(),
                                           bankroll: 6351,
                                           recentSessionAmount: 150,
                                           chartData: FakeData.mockDataCoords,
                                           hourlyRate: 32,
                                           totalSessions: 14))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
