//
//  LineChartFullScreen.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/4/24.
//

import SwiftUI

struct LineChartFullScreen: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    var body: some View {
        
        NavigationView {
            VStack {
                SwiftLineChartsPractice(dateRange: viewModel.sessions, 
                                        showTitle: false,
                                        showYAxis: true,
                                        overlayAnnotation: true)
                .transaction { transaction in
                    transaction.animation = .none
                }
                
            }
            .transaction { transaction in
                transaction.animation = .none
            }
        .padding(.bottom, 50)
        }
        
    }
}

#Preview {
    LineChartFullScreen()
        .environmentObject(SessionsListViewModel())
}
