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
    
    let mockData = [880, 260, 615, 920, 2412, 1300, 790]
    
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
                        
                        HStack (alignment: .bottom, spacing: 20) {
                            ForEach(0..<viewModel.dailyChart().count) { weekday in
                                
                                VStack {
                                    Spacer()

                                    Text(String(viewModel.dailyBarChart()[weekday].accountingStyle()))
                                        .font(.caption)
                                    
                                    LinearGradient(gradient: Gradient(colors: [Color("lightGreen"), .green]),
                                                   startPoint: .top,
                                                   endPoint: .bottomTrailing)
                                        .frame(maxWidth: .infinity, maxHeight: CGFloat(normalizeData(value: viewModel.dailyBarChart()[weekday])) * multiplier)
                                        .clipShape(Capsule())
                                        .padding(.horizontal, 5)
                                        .opacity(0.8)
                                    
                                    Text(viewModel.dailyChart()[weekday].0)
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                        .padding(.top, 10)
                                }
//                                .animation(.easeInOut(duration: 1))
                            }
                        }
                        .padding()
                    }
//                    .onAppear {
//                        withAnimation {
//                            capsulesAppearing.toggle()
//                        }
//                    }
                }
    }
    
    func normalizeData(value: Int) -> Double {
        let normalized = Double(value) - 1 / (Double(viewModel.dailyBarChart().max() ?? 1) - Double(viewModel.dailyBarChart().min() ?? 1))
        return normalized
    }
}

struct BarGraphView_Previews: PreviewProvider {
    static var previews: some View {
        BarGraphView().environmentObject(SessionsListViewModel())
            .frame(height: 400)
    }
}
