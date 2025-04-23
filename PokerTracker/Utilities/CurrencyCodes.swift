//
//  CurrencyCodes.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/22/25.
//

import Foundation

enum CurrencyType: String, CaseIterable, Identifiable, Codable {
    case USD
    case CAD
    case EUR
    case GBP
    case BRL
    case SGD
    case MXN
    case CNY
    case JPY
    case PHP
    case SEK
    case INR
    case THB
    
    var id: String { self.rawValue }
    
    var name: String {
        switch self {
        case .USD: return "US Dollar"
        case .CAD: return "Canadian Dollar"
        case .EUR: return "Euro"
        case .GBP: return "British Pound"
        case .BRL: return "Brazilian Real"
        case .SGD: return "Singapore Dollar"
        case .MXN: return "Mexican Peso"
        case .CNY: return "Chinese Yuan"
        case .JPY: return "Japanese Yen"
        case .PHP: return "Philippines Peso"
        case .SEK: return "Swedish Krona"
        case .INR: return "Indian Rupee"
        case .THB: return "Thai Baht"
        }
    }
    
    var symbol: String {
        switch self {
        case .USD: return "$"
        case .CAD: return "C$"
        case .EUR: return "€"
        case .GBP: return "£"
        case .BRL: return "R$"
        case .SGD: return "S$"
        case .MXN: return "MX$"
        case .CNY: return "¥"
        case .JPY: return "¥"
        case .PHP: return "₱"
        case .SEK: return "kr"
        case .INR: return "₹"
        case .THB: return "฿"
        }
    }
    
    var symbolWidth: Int {
        symbol.count > 1 ? 30 : 15
    }
}
