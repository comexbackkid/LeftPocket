//
//  SleepChart.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 5/1/24.
//

//import SwiftUI
//import Charts
//
//struct SleepChart: View {
//    
//    @StateObject var viewModel = SleepChartViewModel()
//
//    var body: some View {
//        
//        VStack {
//            if viewModel.sessionDataPoints.isEmpty {
//                
//                Text("Loading data...")
//                    .onAppear {
//                        Task {
//                            await viewModel.loadRecentSessionsData()
//                        }
//                    }
//                
//            } else {
//                
//                VStack {
//                    Chart {
//                        ForEach(viewModel.sessionDataPoints) { dataPoint in
//                            LineMark(
//                                x: .value("Date", dataPoint.session.date),
//                                y: .value("Hourly Rate", dataPoint.session.hourlyRate)
//                            )
//                            .foregroundStyle(.blue)
//                            .symbol(Circle())
//                        }
//                    }
//                    
//                    
//                    Chart {
//                        ForEach(viewModel.sessionDataPoints) {dataPoint in
//                            BarMark(
//                                x: .value("Date", dataPoint.session.date),
//                                y: .value("Hours of Sleep", dataPoint.sleepHours))
//                        }
//                        .foregroundStyle(.orange.gradient)
//                    }
//                    .frame(height: 70)
////                    .chartYAxis(.hidden)
////                    .chartXAxis(.hidden)
//                }
//                .padding()
//            }
//        }
//    }
//}
//
//#Preview {
//    SleepChart()
//}
