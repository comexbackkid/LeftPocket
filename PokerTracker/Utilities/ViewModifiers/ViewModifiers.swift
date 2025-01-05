//
//  ViewModifiers.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/27/21.
//

import SwiftUI

struct AccountingView: ViewModifier {
    
    let total: Int
    
    func body(content: Content) -> some View {
        content
            .foregroundColor( total > 0 ? Color.lightGreen : total < 0 ? .red : Color(.systemGray))
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
