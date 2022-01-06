//
//  CustomChartView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 12/2/21.
//

import SwiftUI

struct CustomChartView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let data: [Point]
    
    var body: some View {
        ZStack {
            chartBody
                .padding(.top, 50)
                .padding(.bottom)
        }
    }
    
    @State private var isPresented: Bool = false
    
    private var chartBody: some View {
        
        let pathProvider = LineChartProvider(data: data, lineRadius: 0.5)
        
        return GeometryReader { geometry in
            ZStack {
                
                // Background
                pathProvider.closedPath(for: geometry)
                    .fill(
                        LinearGradient(gradient: Gradient(colors: [.white.opacity(colorScheme == .dark ? 0.0 : 1.0), Color("lightBlue").opacity(0.5)]),
                                       startPoint: .bottom,
                                       endPoint: .top)
                    )
                    .opacity(self.isPresented ? 0.5 : 0)
                    .animation(.easeInOut.speed(0.25).delay(0.8), value: isPresented)
                
                // Line
                pathProvider.path(for: geometry)
                    .trim(from: 0, to: isPresented ? 1 : 0)
                    .stroke(
                        LinearGradient(gradient: Gradient(colors: [.chartBase, .chartAccent]),
                                       startPoint: .leading,
                                       endPoint: .trailing),
                        style: StrokeStyle(lineWidth: 4)
                    )
                    .animation(.easeInOut(duration: 1.5).delay(0.25), value: isPresented)
            }
            .onAppear {
                DispatchQueue.main.async {
                    isPresented = true
                }
            }
        }
    }
}

struct CustomChartView_Previews: PreviewProvider {
    static var previews: some View {
        CustomChartView(data: MockData.mockDataCoordinates)
    }
}
