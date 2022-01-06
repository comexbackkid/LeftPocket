//
//  BarGraphView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 11/8/21.
//

import SwiftUI

struct BarGraphView: View {
    
    @State private var capsulesAppearing = false
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    var body: some View {
        
        let multiplier = calculateMultiplier(maxData: viewModel.dailyBarChart().max() ?? 0)
        
        VStack {
            VStack {
                HStack {
                    Text("Total Daily Profit")
                        .font(.title)
                        .bold()
                    Spacer()
                }
                .padding(.horizontal)
                
                ZStack {
                    VStack {
                        ForEach(getGraphLines(), id: \.self) { line in
                            HStack(spacing: 8) {
                                Text("$\(Int(line))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Rectangle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(height: 1)
                            }
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .offset(y: -25)
                        }
                    }
                    .padding()
                    
                    HStack (alignment: .bottom) {
                        ForEach(0..<viewModel.dailyBarChart().count) { weekday in
                            VStack {
                                Spacer()
                                
                                LinearGradient(gradient: Gradient(colors: [Color("lightGreen"), .green]),
                                               startPoint: .top,
                                               endPoint: .bottomTrailing)
                                    .frame(height: capsulesAppearing
                                           ? CGFloat(normalizeData(value: viewModel.dailyBarChart()[weekday])) * multiplier
                                           : 0)
                                    .clipShape(Capsule())
                                    .padding(.horizontal, 13)

                                
                                Text(viewModel.daysOfWeekAbr[weekday])
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                                    .bold()
                                    .padding(.top, 10)
                                
                            }
                            .frame(maxWidth: .infinity, maxHeight: 320)
                            
                        }
                    }
                    .padding(.leading, 40)
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                }
                .onAppear {
                    DispatchQueue.main.async {
                        withAnimation(.easeInOut(duration: 1.5).delay(1.75)) {
                            capsulesAppearing = true
                        }
                    }
                }
            }

        }
    }
    
    // Multiplier dictates how scaled the bar looks
    func calculateMultiplier(maxData: Int) -> CGFloat {
        let frameHeight = 300.0
        let howMuchToFill = 0.8
        return CGFloat((frameHeight / Double(maxData)) * howMuchToFill)
    }
    
    // Normalizes data between 0 and 1. Should we make this a Generic func that conforms to Numeric?
    func normalizeData(value: Int) -> Double {
        let normalized = Double(value) - Double(viewModel.dailyBarChart().min() ?? 0) / (Double(viewModel.dailyBarChart().max() ?? 1) - Double(viewModel.dailyBarChart().min() ?? 1))
        return normalized
    }
    
    // Getting max line height for gray indicator lines
    func getMax() -> CGFloat {
        let max = viewModel.dailyBarChart().max { $1 > $0 } ?? 0
        return CGFloat(max)
    }
    
    // Creating 5 indicator lines
    func getGraphLines() -> [CGFloat] {
        let max = getMax()
        var lines: [CGFloat] = []
        lines.append(max)
        for index in 1...4 {
            let progress = max / 4
            lines.append(max - (progress * CGFloat(index)))
        }
        return lines
    }
}

struct BarGraphView_Previews: PreviewProvider {
    static var previews: some View {
        BarGraphView().environmentObject(SessionsListViewModel())
            .frame(height: 340)
    }
}
