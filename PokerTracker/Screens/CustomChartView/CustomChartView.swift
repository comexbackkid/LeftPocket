//
//  CustomChartView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 12/2/21.
//

import SwiftUI

struct CustomChartView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: SessionsListViewModel
    @State private var isPresented: Bool = false
    
    let data: [Point]
    let background: Bool
    
    var body: some View {
        
        ZStack {
            chartBody
                .padding(.trailing, background ? 70 : 0)
                .background(background ? chartBackground : nil)
                .padding(.top, 50)
                .padding(.bottom)
        }
    }
    
    private var chartBody: some View {
        
        let pathProvider = LineChartProvider(data: data, lineRadius: 0.5)
        
        return GeometryReader { geometry in
            ZStack {
                
                // Background
                if data.count != 1 {
                    pathProvider.closedPath(for: geometry)
                        .fill(
                            LinearGradient(gradient: Gradient(colors: [.white.opacity(colorScheme == .dark ? 0.0 : 0.25), Color("lightBlue").opacity(0.5)]),
                                           startPoint: .bottom,
                                           endPoint: .top)
                        )
                        .opacity(self.isPresented ? 0.5 : 0)
                        .animation(.easeInOut.speed(0.25).delay(0.6), value: isPresented)
                }
                
                // Line
                pathProvider.path(for: geometry)
                    .trim(from: 0, to: isPresented ? 1 : 0)
                    .stroke(
                        LinearGradient(gradient: Gradient(colors: [.chartBase, .chartAccent]),
                                       startPoint: .leading,
                                       endPoint: .trailing),
                        style: StrokeStyle(lineWidth: 3)
                    )
                    .animation(.easeInOut(duration: 1.2).delay(0.2), value: isPresented)
            }
            .onAppear {
                DispatchQueue.main.async {
                    isPresented = true
                }
            }
        }
    }
    
    private var chartBackground: some View {
        
        ZStack {
            VStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 1)
                
                Spacer()
                
                Rectangle()
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 1)
                
                Spacer()
                
                Rectangle()
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 1)
            }
            .padding(.trailing, 55)
            
            VStack {
                
                Text("\(Int(viewModel.chartArray().max() ?? 0).axisFormat)")
                    .offset(y: -8)
                
                Spacer()
                
                Text("\(((Int(viewModel.chartArray().min() ?? 0) + Int(viewModel.chartArray().max() ?? 0))/2).axisFormat)")
                
                Spacer()
                
                Text("\(Int(viewModel.chartArray().min() ?? 0).axisFormat)")
                    .offset(y: 8)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.trailing)
    }
}

struct CustomChartView_Previews: PreviewProvider {
    static var previews: some View {
        CustomChartView(viewModel: SessionsListViewModel(), data: MockData.mockDataCoordinates, background: true)
    }
}
