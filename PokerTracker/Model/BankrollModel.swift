//
//  BankrollModel.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 3/31/25.
//

import Foundation

struct Bankroll: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String
    var sessions: [PokerSession_v2]
    var transactions: [BankrollTransaction] = []
}
