//
//  NumberFormatter.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/26/21.
//

import Foundation

// Use to correctly position - or + and $ with Int and return as String
extension Int {
    
    public func asCurrency() -> String {
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = .currency
        numFormatter.maximumFractionDigits = 0
        return numFormatter.string(from: NSNumber(value: self)) ?? "0"
    }
}

// Styling for CustomChart axis labels
extension Int {
    
    // I changed this recently adding the abs() to thousand and million because negative chart values weren't working
    var axisFormat: String {
        let number = Double(self)
        let sign = (self < 0) ? "-" : ""
        let thousand = abs(number) / 1000
        let million = abs(number) / 1000000
        
        if million >= 1.0 {
            return "\(sign)$\(round(million*10)/10)M"
        }
        else if thousand >= 1.0 {
            return "\(sign)$\(round(thousand*10)/10)K"
        }
        else {
            return "\(sign)$\(abs(self))"
        }
    }
    
    var abbreviateHourTotal: String {
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
            return "\(abs(self))"
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
