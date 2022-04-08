//
//  NewChartView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/7/22.
//

import SwiftUI


// Just keeping this as reference
// It works, but I can't figure out how to implement bezier curves

struct NewChartView: View {
    
    @State private var percentage: CGFloat = 0
    private let data: [Double]
    private let maxY: Double
    private let minY: Double
    private let lineColor = LinearGradient(gradient: Gradient(colors: [.chartBase, .chartAccent]),
                                  startPoint: .leading,
                                  endPoint: .trailing)
    
    init(bankroll: MockData) {
        data = bankroll.chartArray()
        maxY = data.max() ?? 0
        minY = data.min() ?? 0
    }
    
    
    var body: some View {
        VStack {
            chartBody
                .frame(height: 290)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.linear(duration: 1.8)) {
                    percentage = 1.0
                }
            }
        }
    }
}

extension NewChartView {
    private var chartBody: some View {
        GeometryReader { geometry in
            Path { path in
                
                for index in data.indices {
                    
                    let xPosition = geometry.size.width / CGFloat(data.count - 1) * CGFloat(index + 0)
                    let yAxis = maxY - minY
                    let yPosition = (1 - CGFloat((data[index] - minY) / yAxis)) * geometry.size.height
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: xPosition, y: yPosition))
                    }
                    
                    path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                }
            }
            .trim(from: 0, to: percentage)
            .stroke(lineColor, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            .shadow(color: Color.blue, radius: 13, x: 0, y: 20)
        }
    }
}

struct NewChartView_Previews: PreviewProvider {
    static var previews: some View {
        NewChartView(bankroll: MockData())
    }
}
