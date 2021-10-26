//
//  Text+Ext.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 9/13/21.
//

import SwiftUI

// Just placeholder, not using this style at all
extension Text {
    func deepRedTextStyle() -> some View {
            self.foregroundColor(.red)
                .italic()
                .opacity(0.7)
                .font(.subheadline)
        }
}

// Keeps a negative number formatted correctly
extension Text {
    var currencyFormatter: NumberFormatter {
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = .currency
        numFormatter.maximumFractionDigits = 0
        return numFormatter
    }
}
