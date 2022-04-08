//
//  CustomChartView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 12/2/21.
//

import SwiftUI

struct CustomChartView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @State private var isPresented: Bool = false
    
    let data: [Point]
    
    var body: some View {
        
        let maxY = Double(data.max { $0.y < $1.y }?.y ?? 0)
        let minY = Double(data.min { $0.y < $1.y }!.y)
        
        ZStack {
            chartBody
//                .background(
//                    chartBackground
//                )
//                .overlay(
//                    VStack {
//                        Text(maxY.chartAxisStyle())
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                        Spacer()
//                        Text("$8")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                        Spacer()
//                        Text(minY.chartAxisStyle())
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                    }, alignment: .leading
//                )
                .padding(.top, 50)
                .padding(.bottom)
        }
    }
    
    private var chartBody: some View {
        
        let pathProvider = LineChartProvider(data: data, lineRadius: 0.5)
        
        return GeometryReader { geometry in
            ZStack {
                
                // Background
                pathProvider.closedPath(for: geometry)
                    .fill(
                        LinearGradient(gradient: Gradient(colors: [.white.opacity(colorScheme == .dark ? 0.0 : 0.5), Color("lightBlue").opacity(0.5)]),
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
                        style: StrokeStyle(lineWidth: 3)
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
    
    private var chartBackground: some View {
        
            VStack {
                HStack {
                    Text("$50")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 1)
                }
                Spacer()
                HStack {
                    Text("$50")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 1)
                }
                Spacer()
                HStack {
                    Text("$50")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 1)
                }
            }
    }
}

struct CustomChartView_Previews: PreviewProvider {
    static var previews: some View {
        CustomChartView(data: MockData.mockDataCoordinates)
    }
}
