//
//  WidgetViewMedium.swift
//  LeftPocketWidgetExtension
//
//  Created by Christian Nachtrieb on 8/11/22.
//

import SwiftUI
import WidgetKit
import Charts

struct WidgetViewMedium: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var entry: SimpleEntry
    
    var body: some View {
        
        ZStack (alignment: .bottom) {
            
            backgroundGradient
            
            numbers
            
            swiftChart
            
            logo
            
        }
        .widgetBackground(Color.clear)
    }
    
    var backgroundGradient: some View {
        Color("WidgetBackground")
            .overlay(LinearGradient(colors: [Color("WidgetBackround"), .black.opacity(colorScheme == .dark ? 0.8 : 0.1)],
                                    startPoint: .bottomTrailing,
                                    endPoint: .topLeading))
    }
    
    var numbers: some View {
        
        VStack {
            
            HStack(spacing: 40) {
                
                VStack(alignment: .leading) {
                    
                    Text("Hourly Rate")
                        .foregroundColor(.secondary)
                        .font(.custom("Asap-Regular", size: 12))
                    
                    Text(entry.hourlyRate, format: .currency(code: entry.currency).precision(.fractionLength(0)))
                        .foregroundColor(.widgetForegroundText)
                        .font(.custom("Asap-Medium", size: 18))
                }
                
                VStack (alignment: .leading) {
                    
                    Text("Sessions")
                        .foregroundColor(.secondary)
                        .font(.custom("Asap-Regular", size: 12))
                    
                    Text("\(entry.totalSessions)")
                        .foregroundColor(.widgetForegroundText)
                        .font(.custom("Asap-Medium", size: 18))
                }
                
                Spacer()
            }
            .padding(.top, 12)
            
            Spacer()

            HStack {
                Text("Total Profit")
                    .font(.custom("Asap-Regular", size: 12))
                    .foregroundColor(.secondary)

                Spacer()
            }
            HStack {
                Text(entry.bankroll, format: .currency(code: entry.currency).precision(.fractionLength(0)))
                    .foregroundColor(.widgetForegroundText)
                    .font(.custom("Asap-Bold", size: 28))
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                
                Spacer()
            }
            
            HStack {
                
                if entry.recentSessionAmount != 0 {
                    Image(systemName: "arrow.up.right")
                        .resizable()
                        .frame(width: 11, height: 11)
                        .foregroundColor(entry.recentSessionAmount > 0 ? Color.lightGreen : entry.recentSessionAmount < 0 ? .red : Color(.systemGray))
                        .rotationEffect(entry.recentSessionAmount >= 0 ? .degrees(0) : .degrees(90))
                }
                
                Text(entry.recentSessionAmount, format: .currency(code: entry.currency).precision(.fractionLength(0)))
                    .foregroundColor(entry.recentSessionAmount > 0 ? Color.lightGreen : entry.recentSessionAmount < 0 ? .red : Color(.systemGray))
                    .font(.custom("Asap-Medium", size: 18))
                
                Spacer()
            }
            .padding(.top, -18)
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }
    
    var swiftChart: some View {
        
        HStack {
            
            Spacer()
            
            Chart {
                ForEach(Array(entry.swiftChartData.enumerated()), id: \.offset) { index, total in
                    
                    LineMark(x: .value("Time", index), y: .value("Profit", total))
                        .foregroundStyle(LinearGradient(colors: [.chartAccent, .chartBase], startPoint: .topTrailing, endPoint: .bottomLeading))
                        
                    
                    AreaMark(x: .value("Time", index), y: .value("Profit", total))
                        .foregroundStyle(LinearGradient(colors: [Color("lightBlue").opacity(0.4), .clear], startPoint: .top, endPoint: .bottom))
                }
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            }
            .overlay(
                PatternView()
                    
                    .allowsHitTesting(false)
                    .mask(
                        Chart {
                            ForEach(Array(entry.swiftChartData.enumerated()), id: \.offset) { index, total in
                                AreaMark(x: .value("Time", index), y: .value("Profit", total))
                            }
                            .interpolationMethod(.catmullRom)
                        }
                    )
            )
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(maxWidth: 165, maxHeight: 75)
            .padding(.trailing, 15)
            .padding(.bottom, 15)
        }
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
}

struct PatternView: View {
    
    var body: some View {
        
        GeometryReader { geometry in
            let patternSize: CGFloat = 3 // Size of individual dots
            let spacing: CGFloat = 7 // Spacing between dots
            let dotColor: Color = Color("lightBlue").opacity(0.1)

            Canvas { context, size in
                for y in stride(from: 0, to: size.height, by: patternSize + spacing) {
                    for x in stride(from: 0, to: size.width, by: patternSize + spacing) {
                        context.fill(
                            Path(ellipseIn: CGRect(x: x, y: y, width: patternSize, height: patternSize)),
                            with: .color(dotColor)
                        )
                    }
                }
            }
        }
    }
}

struct WidgetViewMedium_Previews: PreviewProvider {
    static var previews: some View {
        WidgetViewMedium(entry: SimpleEntry(date: Date(),
                                            bankroll: 63351,
                                            recentSessionAmount: 150,
                                            swiftChartData: [0,350,220,457,900,719,333,1211,1400,1765,1500,1828,1721],
                                            hourlyRate: 32,
                                            totalSessions: 14,
                                            currency: "USD"))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .preferredColorScheme(.dark)
        
    }
}
