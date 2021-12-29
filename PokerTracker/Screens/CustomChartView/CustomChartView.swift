//
//  CustomChartView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 12/2/21.
//

import SwiftUI



struct CustomChartView: View {
    
    let data: [Point]
    
    var body: some View {
        ZStack {
            chartBody
                .padding(.top, 50)
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
                        LinearGradient(gradient: Gradient(colors: [.white, Color("lightBlue").opacity(0.1)]),
                                       startPoint: .bottom,
                                       endPoint: .top)
                    )
                    .opacity(self.isPresented ? 0.5 : 0)
                    .animation(Animation.easeInOut(duration: 1.5).delay(0.6))
                
                // Line
                pathProvider.path(for: geometry)
                    .trim(from: 0, to: isPresented ? 1 : 0)
                    .stroke(
                        LinearGradient(gradient: Gradient(colors: [.brandPrimary, Color("lightBlue")]),
                                       startPoint: .leading,
                                       endPoint: .trailing),
                        style: StrokeStyle(lineWidth: 4)
                    )
                    .animation(Animation.easeInOut(duration: 1.5).delay(0.3))
            }
            .onAppear {
                isPresented = true
            }
        }
    }
    
    
    //    private var gridBody: some View {
    //        GeometryReader { geometry in
    //            Path { path in
    //                let xStepWidth = geometry.size.width / CGFloat(self.xStepsCount)
    //                let yStepWidth = geometry.size.height / CGFloat(self.yStepsCount)
    //
    //                (1...self.yStepsCount).forEach { index in
    //                    let y = CGFloat(index) * yStepWidth
    //                    path.move(to: .init(x: 0, y: y))
    //                    path.addLine(to: .init(x: geometry.size.width, y: y))
    //                }
    //
    //                (1...self.xStepsCount).forEach { index in
    //                    let x = CGFloat(index) * xStepWidth
    //                    path.move(to: .init(x: x, y: 0))
    //                }
    //            }
    //            .stroke(
    //                Color.black,
    //                style: StrokeStyle(lineWidth: 3))
    //        }
    //    }
    
    
    
    
}

struct CustomChartView_Previews: PreviewProvider {
    static var previews: some View {
        CustomChartView(data: MockData.mockDataCoordinates)
    }
}
