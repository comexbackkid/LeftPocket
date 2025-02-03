//
//  RangeFilter+Ext.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 6/28/24.
//

import Foundation
import SwiftUI

enum RangeSelection: String, CaseIterable {
    case all, oneMonth, threeMonth, sixMonth, oneYear, ytd
    
    var displayName: String {
            switch self {
            case .all:
                return "All"
            case .oneMonth:
                return "1M"
            case .threeMonth:
                return "3M"
            case .sixMonth:
                return "6M"
            case .oneYear:
                return "1Y"
            case .ytd:
                return "YTD"
            }
        }
}

extension SessionsListViewModel {
    
    func filterSessionsYTD() -> [PokerSession_v2] {
        let calendar = Calendar.current
        let now = Date()
        
        guard let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now)) else {
            return []
        }
        
        return sessions.filter { session in
            return session.date >= startOfYear
        }
    }
    
    func filterSessionsLastTwelveMonths() -> [PokerSession_v2] {
        let calendar = Calendar.current
        let twelveMonthsAgo = calendar.date(byAdding: .month, value: -12, to: Date())

        return sessions.filter { session in
            guard let twelveMonthsAgo = twelveMonthsAgo else { return false }
            return session.date >= twelveMonthsAgo
        }
    }
    
    func filterSessionsLastSixMonths() -> [PokerSession_v2] {
        let calendar = Calendar.current
        let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: Date())

        return sessions.filter { session in
            guard let sixMonthsAgo = sixMonthsAgo else { return false }
            return session.date >= sixMonthsAgo
        }
    }
    
    func filterSessionsLastThreeMonths() -> [PokerSession_v2] {
        let calendar = Calendar.current
        let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: Date())
        
        return sessions.filter { session in
            guard let threeMonthsAgo = threeMonthsAgo else { return false }
            return session.date >= threeMonthsAgo
        }
    }
    
    func filterSessionsLastMonth() -> [PokerSession_v2] {
        let calendar = Calendar.current
        let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: Date())

        return sessions.filter { session in
            guard let oneMonthAgo = oneMonthAgo else { return false }
            return session.date >= oneMonthAgo
        }
    }
}
