
//  SwiftChartsPractice.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 10/17/22.
//

import SwiftUI
import Charts

struct DummySession: Identifiable, Hashable {
    var id = UUID()
    let date: Date
    let profit: Int
}

struct SwiftLineChartsPractice: View {
    
    let dummyData: [DummySession] = [
        
        DummySession(date: Date.from(year: 2023, month: 1, day: 11), profit: 150),
        DummySession(date: Date.from(year: 2023, month: 1, day: 15), profit: 90),
        DummySession(date: Date.from(year: 2023, month: 2, day: 1), profit: -20),
        DummySession(date: Date.from(year: 2023, month: 3, day: 2), profit: 224),
        DummySession(date: Date.from(year: 2023, month: 3, day: 8), profit: 20),
        DummySession(date: Date.from(year: 2023, month: 4, day: 3), profit: -100),
        DummySession(date: Date.from(year: 2023, month: 4, day: 10), profit: 612),
        DummySession(date: Date.from(year: 2023, month: 4, day: 17), profit: 105),
        DummySession(date: Date.from(year: 2023, month: 5, day: 16), profit: 410),
        DummySession(date: Date.from(year: 2023, month: 6, day: 2), profit: -75),
        DummySession(date: Date.from(year: 2023, month: 6, day: 9), profit: -200),
        DummySession(date: Date.from(year: 2023, month: 6, day: 14), profit: 480),
        DummySession(date: Date.from(year: 2023, month: 6, day: 29), profit: 100),
        DummySession(date: Date.from(year: 2023, month: 8, day: 11), profit: 234),
        DummySession(date: Date.from(year: 2023, month: 8, day: 12), profit: -90),
        DummySession(date: Date.from(year: 2023, month: 9, day: 8), profit: 175),
        DummySession(date: Date.from(year: 2023, month: 11, day: 11), profit: 40),
        DummySession(date: Date.from(year: 2023, month: 12, day: 1), profit: 75),
        DummySession(date: Date.from(year: 2023, month: 12, day: 4), profit: 150)
    ]
    
    var body: some View {
        
        VStack {
            
            Chart {
                ForEach(Array(dummyData.enumerated()), id: \.element.id) { index, session in
                    LineMark(x: .value("Month", index),
                             y: .value("Profit", session.profit))
                    .lineStyle(.init(lineWidth: 3.0, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(LinearGradient(colors: [.purple.opacity(0.05), .blue], startPoint: .bottomLeading, endPoint: .topTrailing))
                }
                .interpolationMethod(.catmullRom(alpha: 0))
            }
            .chartXAxis(.hidden)
            .chartXAxis {
                AxisMarks(stroke: StrokeStyle(lineWidth: 1))
            }
            .chartYAxis {
                AxisMarks(position: .trailing, values: .automatic) { value in
                    AxisGridLine()
                    AxisValueLabel() {
                        if let intValue = value.as(Int.self) {
                            Text(intValue.asCurrency())
                                .padding(.leading, 25)
                        }
                    }
                }
            }
            //                    .chartYScale(domain: dummyData.map { $0.profit }.min()!...dummyData.map{ $0.profit }.max()!)
        }
        
    }
}

//struct SwiftBarChartsPractice: View {
//    
//    @EnvironmentObject var viewModel: SessionsListViewModel
//    
//    @State private var selectedDate: Date?
//    
//    let dummyData: [DummySession] = [
//        
//        DummySession(date: Date.from(year: 2023, month: 1, day: 11), profit: 150),
//        DummySession(date: Date.from(year: 2023, month: 1, day: 15), profit: 90),
//        DummySession(date: Date.from(year: 2023, month: 2, day: 1), profit: -150),
//        DummySession(date: Date.from(year: 2023, month: 3, day: 2), profit: 224),
//        DummySession(date: Date.from(year: 2023, month: 3, day: 8), profit: 20),
//        DummySession(date: Date.from(year: 2023, month: 4, day: 3), profit: -100),
//        DummySession(date: Date.from(year: 2023, month: 4, day: 10), profit: 612),
//        DummySession(date: Date.from(year: 2023, month: 4, day: 17), profit: 105),
//        DummySession(date: Date.from(year: 2023, month: 5, day: 16), profit: 410),
//        DummySession(date: Date.from(year: 2023, month: 6, day: 2), profit: -75),
//        DummySession(date: Date.from(year: 2023, month: 6, day: 14), profit: 480),
//        DummySession(date: Date.from(year: 2023, month: 6, day: 29), profit: 100),
//        DummySession(date: Date.from(year: 2023, month: 8, day: 11), profit: 234),
//        DummySession(date: Date.from(year: 2023, month: 8, day: 12), profit: -90),
//        DummySession(date: Date.from(year: 2023, month: 9, day: 8), profit: 175),
//        DummySession(date: Date.from(year: 2023, month: 11, day: 11), profit: -40),
//        DummySession(date: Date.from(year: 2023, month: 12, day: 1), profit: 75),
//        DummySession(date: Date.from(year: 2023, month: 12, day: 4), profit: 150)
//    ]
//    let firstDay: Date = Date.from(year: Int(Date().getYear())!, month: 1, day: 1)
//    let lastDay: Date = Date.from(year: Int(Date().getYear())!, month: 12, day: 31)
//    
//    var modifiedSessions: [(month: Date, profit: Int)] {
//        let newArray = sessionsByMonth(sessions: viewModel.sessions)
//        return newArray
//    }
//    var bestMonth: String {
//        
//        mostProfitableMonth(in: viewModel.sessions)
//        
//    }
//    var profitAnnotation: Int {
//        
//        profitByMonth(month: selectedDate!, data: viewModel.sessions)
//        
//    }
//    
//    var body: some View {
//        
//        VStack (alignment: .leading) {
//            
////            Text("Your \(Text("best month").bold()) so far this year has been \(bestMonth). Keep it up!")
////                .calloutStyle()
////                .padding(.bottom, 40)
//            
//            HStack {
//                Text("Monthly Totals")
//                    .cardTitleStyle()
//                
//                Spacer()
//                
//            }
//            .padding(.bottom, 40)
//            
//            Chart {
//                
//                // The reason for the ForEach statement is because it's the only way to use the 'if let' statement getting
//                // values from RuleMark and using it as an overlay
//                ForEach(modifiedSessions, id: \.month) { pokerSession in
//                    
//                    BarMark(x: .value("Month", pokerSession.month, unit: .month), y: .value("Profit", pokerSession.profit))
//                        .cornerRadius(5)
//                        .foregroundStyle(.pink.gradient)
////                        .opacity(selectedDate == nil || selectedDate?.getMonth() == pokerSession.date.getMonth() ? 1 : 0.5)
//                }
//                
//                if let selectedDate {
//                    RuleMark(x: .value("Selected Date", selectedDate, unit: .month))
//                        .foregroundStyle(.gray.opacity(0.3))
//                        .zIndex(-1)
//                        .annotation(position: .top, spacing: 7, overflowResolution: .init(x: .fit(to: .chart))) {
//                            Text(profitAnnotation.asCurrency())
//                                .captionStyle()
//                                .padding(10)
//                                .background(.gray.opacity(0.1))
//                                .cornerRadius(10)
//                        }
//                }
//            }
//            .chartXScale(domain: [firstDay, lastDay])
//            .chartXSelection(value: $selectedDate)
//            .chartYAxis {
//                AxisMarks(position: .leading) { value in
//                    AxisGridLine()
//                        .foregroundStyle(.gray.opacity(0.2))
//                    AxisValueLabel() {
//                        if let intValue = value.as(Int.self) {
//                            Text(intValue.asCurrency())
//                                .padding(.trailing, 15)
//                        }
//                    }
//                }
//            }
//            .chartXAxis {
//                AxisMarks {
//                    AxisValueLabel(format: .dateTime.month(.abbreviated), verticalSpacing: 15)
//                }
//            }
//        }
//    }
//    
//    func mostProfitableMonth(in sessions: [PokerSession]) -> String {
//            // Create a dictionary to store total profit for each month
//            var monthlyProfits: [Int: Int] = [:]
//
//        // Iterate through sessions and accumulate profit for each month
//            for session in sessions {
//                let month = Calendar.current.component(.month, from: session.date)
//                monthlyProfits[month, default: 0] += session.profit
//            }
//
//            // Find the month with the highest profit
//            if let mostProfitableMonth = monthlyProfits.max(by: { $0.value < $1.value }) {
//                let monthFormatter = DateFormatter()
//                monthFormatter.dateFormat = "MMMM"
//                let monthString = monthFormatter.monthSymbols[mostProfitableMonth.key - 1]
//                return monthString
//            } else {
//                return "No data available"
//            }
//        }
//    
//    func sessionsByMonth(sessions: [PokerSession]) -> [(month: Date, profit: Int)] {
//        
//        // Create a dictionary to store total profit for each month
//            var monthlyProfits: [Date: Int] = [:]
//
//            // Iterate through sessions and accumulate profit for each month
//            for session in sessions {
//                let month = Calendar.current.startOfMonth(for: session.date)
//                monthlyProfits[month, default: 0] += session.profit
//            }
//
//            // Convert the dictionary to an array of tuples
//            let result = monthlyProfits.map { (month: $0.key, profit: $0.value) }
//            
//            return result
//    }
//    
//    // For use in calculating annoations value
//    func profitByMonth(month: Date, data: [PokerSession]) -> Int {
//        
//        let relevantSessions = data.filter({ $0.date.getMonth() == month.getMonth() }).map({ $0.profit }).reduce(0, +)
//        return relevantSessions
//    }
//}

struct SwiftChartsPractice_Previews: PreviewProvider {
    
    static var previews: some View {
        SwiftLineChartsPractice()
    }
}
