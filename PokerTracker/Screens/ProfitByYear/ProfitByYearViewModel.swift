//
//  ProfitByYearViewModel.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 1/6/22.
//

import SwiftUI

class ProfitByYearViewModel: ObservableObject {
    
    @Published var timeline: String = Year.ytd.yearSelection() {
        didSet {
            loadingChart()
        }
    }
    
    @Published var isLoading: Bool = false
    
    func loadingChart() {
        self.isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
        }
    }
}

enum Year {
    case ytd
    case last
    case all
    
    func yearSelection() -> String {
        switch self {
        case .ytd:
            return Date().getYear()
            
        case .last:
            return Date().modifyDays(days: -365).getYear()
        
        case .all:
            return "All"
            
        default:
            return ""
        }
    }
}
