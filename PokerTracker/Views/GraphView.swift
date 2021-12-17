//
//  GraphView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 12/16/21.
//

import SwiftUI

struct GraphView: View {
    let dataPoints: [CGFloat] = [1, 0.8, 0.7, 0.5, 0.7, 0.4, 0.5, 0.6, 0.8, 0.4, 0.3, 0.4, 0.5, 0.7, 0.6, 1]

        var body: some View {
            ZStack{
                LinearGradient(gradient:
                                Gradient(colors: [.brandPrimary, Color(.white)]), startPoint: .top, endPoint: .bottom)
                    .clipShape(LineGraph(dataPoints: dataPoints, closed: true))  // << !!

                LineGraph(dataPoints: dataPoints)
                    .stroke(Color(#colorLiteral(red: 0.2784313725, green: 0.2901960784, blue: 0.9568627451, alpha: 1)), lineWidth: 4)
            }
            .frame(height: 240, alignment: .center)
        }
        
    }


    struct LineGraph: Shape {
        var dataPoints: [CGFloat]
        var closed = false        // << indicator for variants !!
        
        func path(in rect: CGRect) -> Path {
            
            func point(at ix: Int) -> CGPoint {
                let point = dataPoints[ix]
                let x = rect.width * CGFloat(ix) / CGFloat(dataPoints.count - 1)
                let y = (1 - point) * rect.height
                
                return CGPoint(x: x, y: y)
            }
            
            return Path { p in
                
                guard dataPoints.count > 1 else {return}
                
                let start = dataPoints[0]
                p.move(to: CGPoint(x: 0, y: (1 - start) * rect.height))
                
                for index in dataPoints.indices {
                    p.addLine(to: point(at: index))
                }

                if closed {   // << variant for clipping !!
                    p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                    p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
                    p.closeSubpath()
                }
            }
        }
    }

struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        GraphView()
    }
}
