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
            .foregroundColor( total > 0 ? .green : total < 0 ? .red : Color(.systemGray))
    }
}


struct Primary: ViewModifier {
    private let font: Font
    
    init(size: CGFloat, foregroundColor: Color) {
//        self.font = .system(size: UIFontMetrics.default.scaledValue(for: size))
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
