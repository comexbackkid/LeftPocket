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
        .widgetBackground(Color.clear)
    }
        
    var backgroundGradient: some View {
        Color("WidgetBackground")
            .overlay(LinearGradient(colors: [Color("WidgetBackround"), .black.opacity(colorScheme == .dark ? 0.8 : 0.1)],
                                    startPoint: .bottomTrailing,
                                    endPoint: .topLeading))
    }
    
    var logo: some View {
        VStack {
            VStack {
                HStack {
                    Spacer()
                    Image("logo-tiny")
                        .resizable()
                        .frame(width: 34, height: 34)
                        .clipShape(.circle)
                }
            }
            .padding(13)
            Spacer()
        }
    }
    
    var numbers: some View {
        
        VStack {
            
            HStack {
                Text("Hourly Rate")
                    .foregroundColor(.secondary)
                    .font(.custom("Asap-Regular", size: 12))
                
                Spacer()
            }
            
            HStack {
                Text(entry.hourlyRate, format: .currency(code: entry.currency).precision(.fractionLength(0)))
                    .foregroundColor(.widgetForegroundText)
                    .font(.custom("Asap-Medium", size: 18))
                
                Spacer()
            }
            
            Spacer()

            HStack {
                Text("Total Profit")
                    .foregroundColor(.secondary)
                    .font(.custom("Asap-Regular", size: 12))
                
                Spacer()
            }
            HStack {
                Text(entry.bankroll, format: .currency(code: entry.currency).precision(.fractionLength(0)))
                    .foregroundColor(.widgetForegroundText)
                    .font(.custom("Asap-Bold", size: 28))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer()
            }
            
            HStack {
                if entry.recentSessionAmount != 0 {
                    Image(systemName: "arrow.up.right")
                        .resizable()
                        .frame(width: 11, height: 11)
                        .modifier(BasicProfitColor(value: entry.recentSessionAmount))
                        .rotationEffect(entry.recentSessionAmount >= 0 ? .degrees(0) : .degrees(90))
                }
                
                Text(entry.recentSessionAmount, format: .currency(code: entry.currency).precision(.fractionLength(0)))
                    .modifier(BasicProfitColor(value: entry.recentSessionAmount))
                    .font(.custom("Asap-Medium", size: 16))

                
                Spacer()
            }
            .padding(.top, -18)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
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

struct BasicProfitColor: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var value: Int
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(colorForValue(value))
    }
    
    private func colorForValue(_ value: Int) -> Color {
        if value > 0 {
            return colorScheme == .dark ? Color.lightGreen : .green
        } else if value < 0 {
            return .red
        } else {
            return Color(.systemGray)
        }
    }
}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetViewSmall(entry: SimpleEntry(date: Date(),
                                           bankroll: 267351,
                                           recentSessionAmount: 150,
                                           swiftChartData: [0, 5, 20],
                                           hourlyRate: 32,
                                           totalSessions: 14,
                                           currency: "USD"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .preferredColorScheme(.dark)
    }
}
