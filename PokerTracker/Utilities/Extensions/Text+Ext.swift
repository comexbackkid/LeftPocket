//
//  Text+Ext.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 9/13/21.
//

import SwiftUI


// Keeps a negative number formatted correctly. Am I using this anywhere?
extension Text {
    var currencyFormatter: NumberFormatter {
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = .currency
        numFormatter.maximumFractionDigits = 0
        return numFormatter
    }
}
