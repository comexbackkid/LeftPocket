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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @State private var statsRange: RangeSelection = .all
    @Binding var lineChartFullScreen: Bool
    
    var body: some View {
        
        VStack {
            BankrollLineChart(showTitle: false, showYAxis: true, showRangeSelector: true, overlayAnnotation: true)
        }
        .padding(20)
        .padding(.leading, verticalSizeClass == .regular ? 0 : 50)
        .padding(.top, verticalSizeClass == .regular ? 0 : 25)
        .overlay {
            HStack {
                VStack {
                    dismissButton
                    Spacer()
                }
                Spacer()
            }
            .padding(12)
            .padding(.leading, verticalSizeClass == .regular ? 0 : 48)
        }
        .frame(width: UIScreen.main.bounds.width)
        .interfaceOrientations(.allButUpsideDown)
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
