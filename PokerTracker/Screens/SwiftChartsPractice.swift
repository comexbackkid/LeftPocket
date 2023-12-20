//
//  SwiftChartsPractice.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 10/17/22.
//

import SwiftUI
import Charts

//let viewMonths: [ViewMonth] = [
//    .init(date: Date.from(year: 2023, month: 1, day: 1), viewCount: 100),
//    .init(date: Date.from(year: 2023, month: 2, day: 1), viewCount: 190),
//    .init(date: Date.from(year: 2023, month: 3, day: 1), viewCount: 230),
//    .init(date: Date.from(year: 2023, month: 4, day: 1), viewCount: 78),
//    .init(date: Date.from(year: 2023, month: 5, day: 1), viewCount: 120),
//    .init(date: Date.from(year: 2023, month: 6, day: 1), viewCount: 320),
//    .init(date: Date.from(year: 2023, month: 7, day: 1), viewCount: 220)
//]


struct fakeSession: Identifiable {
    var id = UUID()
    let month: String
    let profit: Double
}

struct dummySession: Identifiable {
    var id = UUID()
    let date: Date
    let profit: Int
}

struct SwiftChartsPractice: View {
    
    let dummyData: [dummySession] = [
        .init(date: Date.from(year: 2023, month: 1, day: 1), profit: 100),
        .init(date: Date.from(year: 2023, month: 2, day: 12), profit: 55),
        .init(date: Date.from(year: 2023, month: 3, day: 20), profit: 376),
        .init(date: Date.from(year: 2023, month: 4, day: 2), profit: 246),
        .init(date: Date.from(year: 2023, month: 5, day: 18), profit: 500),
        .init(date: Date.from(year: 2023, month: 11, day: 11), profit: 412),
        .init(date: Date.from(year: 2023, month: 12, day: 11), profit: 480)
    ]
    
    @ObservedObject var vm: SessionsListViewModel
    @State private var selection: FilterType = .monthly
    
    enum FilterType: String, Identifiable, CaseIterable {
        case weekly, monthly, quarterly
        
        var id: String { self.rawValue }
        var component: Calendar.Component {
            switch self {
            case .weekly: return .weekOfYear
            case .monthly: return .month
            case .quarterly: return .quarter
            }
        }
    }
    
    var gradientColor: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    Color.blue.opacity(0.8),
                    Color.blue.opacity(0.01),
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var body: some View {
        
        VStack (alignment: .leading) {
            if #available(iOS 16.0, *) {
                
                VStack {
                    Chart {
                        ForEach(dummyData) { session in
                            LineMark(x: .value("Month", session.date.getMonth()),
                                     y: .value("Profit", session.profit))
                            .lineStyle(.init(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                            .foregroundStyle(LinearGradient(colors: [.purple.opacity(0.05), .blue], startPoint: .bottomLeading, endPoint: .topTrailing))
                            
                            AreaMark(x: .value("Month", session.date.getMonth()),
                                     y: .value("Profit", session.profit))
                            .foregroundStyle(LinearGradient(colors: [.blue.opacity(0.3), .blue.opacity(0.03), .blue.opacity(0.00)], startPoint: .top, endPoint: .bottom))
                            
                        }
                        .interpolationMethod(.cardinal)
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
                .frame(maxHeight: 250)
                
                
                
                
                
                
                
//                HStack {
//                    Text("Profit Outlook")
//                        .font(.title2)
//                        .bold()
//
//                    Spacer()
//
//                    Picker(selection: $selection.animation(), label: Text("")) {
//                        ForEach(FilterType.allCases) { item in
//                            Text(item.rawValue.capitalized).tag(item)
//                        }
//                    }
//                }
//                .padding(.bottom)
//
//                Chart {
//                    ForEach(MockData.allSessions, id: \.self) { session in
//                        BarMark(x: .value("Date", session.date, unit: .month), y: .value("Profit", session.profit))
//                            .foregroundStyle(.pink.gradient)
//                            .cornerRadius(6)
//                    }
//                }
//                .frame(height: 300)
//                .chartXAxis {
//                    AxisMarks(values: .automatic) { _ in
//                        AxisValueLabel()
//                    }
//                }
//                .chartYAxis {
//                    AxisMarks(position: .leading, values: .automatic) { value in
//                        AxisGridLine()
//                        AxisValueLabel() {
//                            if let intValue = value.as(Int.self) {
//                                Text(intValue.asCurrency())
//                                    .padding(.trailing, 25)
//                            }
//                        }
//                    }
//                }
                
                
                


//                                Chart {
//                                    ForEach(viewMonths) { viewMonth in
//                                        BarMark(x: .value("Month", viewMonth.date, unit: .month), y: .value("Count", viewMonth.viewCount))
//                                            .foregroundStyle(.pink.gradient)
//                                            .cornerRadius(8)
//                                    }
//                                }
//                                .frame(height: 300)
//                                .chartXAxis {
//                                    AxisMarks(values: viewMonths.map { $0.date }) { date in
//                                        AxisValueLabel(format: .dateTime.month(.narrow), centered: true)
//                                    }
//                                }
//                                .chartYAxis {
//                                  AxisMarks(values: .automatic) { value in
//                                    AxisGridLine()
//
//                                    AxisValueLabel() {
//                                      if let intValue = value.as(Int.self) {
//                                        Text("$\(intValue)")
//                                              .padding(.leading, 30)
//                                      }
//                                    }
//                                  }
//                                }
                
                
            } else {
                // Fallback on earlier versions
            }
        }
        .padding()
    }
}

struct SwiftChartsPractice_Previews: PreviewProvider {
    static var previews: some View {
        SwiftChartsPractice(vm: SessionsListViewModel())
    }
}



extension Date {
    static func from(year: Int, month: Int, day: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: day)
        return Calendar.current.date(from: components)!
    }
}
