//
//  ProfitByYearViewModel.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 1/6/22.
//

import SwiftUI

class ProfitByYearViewModel: ObservableObject {
    
    @Published var selectedTimeline: String = "YTD" {
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
