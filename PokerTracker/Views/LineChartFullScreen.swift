//
//  LineChartFullScreen.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/4/24.
//

import SwiftUI

struct LineChartFullScreen: View {
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    @Environment(\.dismiss) var dismiss
    
    @Binding var lineChartFullScreen: Bool
    
    var body: some View {
        
        VStack {
            SwiftLineChartsPractice(showTitle: false,
                                    showYAxis: true,
                                    showRangeSelector: false,
                                    overlayAnnotation: true)
            
            // Swap width and height to match landscape dimensions
            .transaction { transaction in
                transaction.animation = .none
            }
        }
        .padding(50)
        .overlay {
            HStack {
                VStack {
                    dismissButton
                    Spacer()
                }
                .padding(.leading, 15)
                
                Spacer()
            }
            .padding(35)
        }
        .rotationEffect(.degrees(90)) // Rotate 90 degrees
        .frame(width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width)
    }
    
    var dismissButton: some View {
        
        Button {
            dismiss.callAsFunction()
        } label: {
            DismissButton()
        }
    }
}

#Preview {
    LineChartFullScreen(lineChartFullScreen: .constant(true))
        .environmentObject(SessionsListViewModel())
        .preferredColorScheme(.dark)
}
