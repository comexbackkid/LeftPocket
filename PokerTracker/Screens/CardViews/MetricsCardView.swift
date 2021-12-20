//
//  MetricsCardView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import SwiftUI
import SwiftUICharts

struct MetricsCardView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    let lineChartStyle = ChartStyle(backgroundColor: .white,
                                    accentColor: .brandPrimary,
                                    secondGradientColor: Color("lightBlue"),
                                    textColor: .black,
                                    legendTextColor: .gray,
                                    dropShadowColor: .white)
    
    var body: some View {
        
        ZStack (alignment: .leading) {
            VStack (alignment: .leading) {
                LineChartView(data: viewModel.chartArray(),
                              title: "Total Profit",
                              legend: "Earnings Chart",
                              style: lineChartStyle,
                              form: CGSize(width: 340, height: 240),
                              rateValue: 0,
                              dropShadow: false,
                              valueSpecifier: "%.0f")
                
//                CustomChartView(sessions: viewModel.sessions)
//                    .frame(height: 240)
                
                
                Spacer()
                HStack {
                    VStack (alignment: .leading, spacing: 5) {
                        Text("My Metrics")
                            .font(.title3)
                            .bold()
                        Text("A look at how you've been playing and ways to improve your game.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                    }
                    .padding(.horizontal)
                }
                Spacer()
            }
        }
        .frame(width: 340, height: 360)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.3),
                radius: 12, x: 0, y: 5)
    }
}

struct MetricsCardView_Previews: PreviewProvider {
    static var previews: some View {
        MetricsCardView().environmentObject(SessionsListViewModel())
    }
}
