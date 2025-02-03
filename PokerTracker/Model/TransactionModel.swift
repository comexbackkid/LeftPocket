//
//  TransactionModel.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 1/23/25.
//

import Foundation

struct BankrollTransaction: Hashable, Identifiable, Codable {
    var id = UUID()
    let date: Date
    let type: TransactionType
    let amount: Int
    let notes: String
    let tags: [String]?
}

enum TransactionType: String, Codable, CaseIterable {
    case deposit, withdrawal, expense
    
    var description: String {
        switch self {
        case .deposit:
            "Deposit"
        case .withdrawal:
            "Withdrawal"
        case .expense:
            "Expense"
        }
    }
}
