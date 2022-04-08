//
//  NumberFormatter.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/26/21.
//

import Foundation

// Use to correctly position - or + and $ with Int and return as String
extension Int {
    
    public func accountingStyle() -> String {
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = .currency
        numFormatter.maximumFractionDigits = 0
        return numFormatter.string(from: NSNumber(value: self)) ?? "0"
    }
}

// Styling for CustomChart axis labels
extension Double {
    
    public func chartAxisStyle() -> String {
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = .currency
        numFormatter.maximumFractionDigits = 0
        return numFormatter.string(from: NSNumber(value: self)) ?? "0"
    }
}
