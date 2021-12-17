//
//  CustomChartView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 12/2/21.
//

import SwiftUI

struct CustomChartView: View {
    
    private let data: [Double]
    private let maxY: Double
    private let minY: Double
    
    @State private var percentage: CGFloat = 0
    
    init(sessions: [PokerSession]) {
//        data = sessions.map { Double($0.profit) }
        data = [5, 40, 140, 100, 400, 350, 684, 600]
        maxY = data.max() ?? 0
        minY = data.min() ?? 0
    }
    
    var body: some View {
        VStack {
            chartView
                .frame(maxHeight: 180)
            
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.linear(duration: 1.0)) {
                    percentage = 1.0
                }
            }
        }
    }
}

struct CustomChartView_Previews: PreviewProvider {
    static var previews: some View {
        CustomChartView(sessions: MockData.allSessions)
    }
}

extension CustomChartView {
    
    private var chartView: some View {
        GeometryReader { geometry in
            Path { path in
                for index in data.indices {
                    
                    let xPosition = geometry.size.width / CGFloat(data.count) * CGFloat(index + 0)
                    
                    // Determines the height of the yAxis by subtracting the min & max data points we have
                    let yAxis = maxY - minY
                    
                    let yPosition = (1 - CGFloat((data[index] - minY) / yAxis)) * geometry.size.height
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: xPosition, y: yPosition))
                    }
                    path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                }
            }
            .trim(from: 0, to: percentage)
            .stroke(LinearGradient(colors: [Color.brandPrimary, Color("lightBlue")], startPoint: .leading, endPoint: .trailing), style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
            
        }
    }
}


