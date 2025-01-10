//
//  ViewModifiers.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/27/21.
//

import SwiftUI

// For handling of positive / negative integers coloring on BankrollLineChart
struct PositiveNegativeColorModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var amountText: Int?
    var defaultProfit: Int
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(colorForValue())
    }
    
    private func colorForValue() -> Color {
        let value = (amountText == nil || amountText == 0) ? defaultProfit : amountText!
        
        if value > 0 {
            return colorScheme == .dark ? Color.lightGreen : .green
        } else if value < 0 {
            return .red
        } else {
            return .gray
        }
    }
}

// For handling positive / negative integers coloring
struct MetricsProfitColor: ViewModifier {
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
            return .primary
        }
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

// Handles styling of Card Views located in ContentView
struct CardViewButtonStyle: ButtonStyle {
    
    // This just removes some weird button styling from our custom card view that couldn't otherwise be made
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay {
                
                if configuration.isPressed {
                    Color.black.opacity(0.1).cornerRadius(20)
                    
                } else {
                    Color.clear
                }
            }
    }
}

struct Primary: ViewModifier {
    
    private let font: Font
    
    init(size: CGFloat, foregroundColor: Color) {
        self.font = .custom("Asap-Regular", size: 18)
    }

    init(font: Font) {
        self.font = font
    }

    public func body(content: Content) -> some View {
        content
            .font(font)
    }
}

extension View {
    
    func primary() -> some View {
        ModifiedContent(content: self, modifier: Primary(font: .system(size: 13, weight: .semibold, design: .default)))
    }
    
    func chartIntProfitColor(amountText: Int?, defaultProfit: Int) -> some View {
        self.modifier(PositiveNegativeColorModifier(amountText: amountText, defaultProfit: defaultProfit))
    }
    
    func metricsProfitColor(for value: Int) -> some View {
        self.modifier(MetricsProfitColor(value: value))
    }
    
    func profitColor(total: Int) -> some View {
        self.modifier(BasicProfitColor(value: total))
//        self.foregroundColor( total > 0 ? Color.lightGreen : total < 0 ? .red : Color(.systemGray))
    }
}


