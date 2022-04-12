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
extension Int {
    
    var chartAxisStyle: String {
        let number = Double(self)
        let thousand = number / 1000
        let million = number / 1000000
        
        if million >= 1.0 {
            return "\(round(million*10)/10)M"
        }
        else if thousand >= 1.0 {
            return "\(round(thousand*10)/10)K"
        }
        else {
            return "\(self)"
        }
    }
}

extension Double {
    
    public func asPercent() -> String {
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = .percent
        numFormatter.maximumFractionDigits = 0
        return numFormatter.string(from: NSNumber(value: self)) ?? "%0"
    }
}
