//
//  BarChartView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/8/22.
//

import SwiftUI
import Charts

struct BarChartView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var vm: SessionsListViewModel
    
    var body: some View {
        
        VStack (alignment: .leading) {
            
            HStack {
                Text("Weekday Totals")
                    .cardTitleStyle()
                
                Spacer()
                
            }
            .padding(.bottom, 25)
            
            Chart {
                ForEach(vm.barChartByDay(), id: \.self) { weekday in
                    BarMark(x: .value("Day", weekday.day), y: .value("Profit", weekday.profit))
                        .foregroundStyle(.pink.gradient)
                        .cornerRadius(5)
                }
            }
            .frame(height: 300)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic) { value in
                    AxisGridLine()
                    AxisValueLabel() {
                        if let intValue = value.as(Int.self) {
                            Text(intValue.asCurrency())
                                .padding(.trailing, 25)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
        .cornerRadius(20)
    }
}

struct BarChartView_Previews: PreviewProvider {
    static var previews: some View {
        BarChartView(vm: SessionsListViewModel())
    }
}
