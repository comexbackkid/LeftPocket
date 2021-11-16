//
//  BarGraphView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 11/8/21.
//

import SwiftUI

struct BarGraphView: View {
    
//    @State var capsulesAppearing = false
    
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    func calculateMultiplier(maxData: Int) -> CGFloat {
        let frameHeight = 300.0
        let howMuchToFill = 0.9
        return CGFloat((frameHeight / Double(maxData)) * howMuchToFill)
    }
    
    var body: some View {
        
        let multiplier = calculateMultiplier(maxData: viewModel.dailyBarChart().max() ?? 0)
        
        VStack {
            VStack {
                HStack {
                    Text("Weekday Snapshot")
                        .font(.title)
                        .bold()
                    Spacer()
                }
                .padding(.horizontal)
                
                HStack (alignment: .bottom) {
                    ForEach(0..<viewModel.dailyBarChart().count) { weekday in
                        
                        VStack {
                            Spacer()
                            
                            Text(String(viewModel.dailyBarChart()[weekday].accountingStyle()))
                                .font(.caption)
                            
                            LinearGradient(gradient: Gradient(colors: [Color("lightGreen"), .green]),
                                           startPoint: .top,
                                           endPoint: .bottomTrailing)
                                .frame(width: 12,
                                       height: CGFloat(normalizeData(value: viewModel.dailyBarChart()[weekday])) * multiplier)
                                .clipShape(Capsule())
                                .padding(.horizontal, 5)
                                .opacity(0.8)
                            
                            Text(viewModel.daysOfWeekAbr[weekday])
                                .foregroundColor(.secondary)
                                .font(.caption)
                                .bold()
                                .padding(.top, 10)
                        }
                        .frame(maxWidth: .infinity)
//                        .animation(.easeInOut(duration: 1))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
//            .onAppear {
//                withAnimation {
//                    capsulesAppearing.toggle()
//                }
//            }
        }
    }
    
    // Normalizes data between 0 and 1. Should we make this a Generic func that conforms to Numeric?
    func normalizeData(value: Int) -> Double {
        let normalized = Double(value) - Double(viewModel.dailyBarChart().min() ?? 0) / (Double(viewModel.dailyBarChart().max() ?? 1) - Double(viewModel.dailyBarChart().min() ?? 1))
        return normalized
    }
}

struct BarGraphView_Previews: PreviewProvider {
    static var previews: some View {
        BarGraphView().environmentObject(SessionsListViewModel())
            .frame(height: 320)
    }
}
