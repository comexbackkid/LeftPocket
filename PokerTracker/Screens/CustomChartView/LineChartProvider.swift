//
//  ChartProvider.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/28/21.
//

import Foundation
import SwiftUI

struct Point: Codable {
    let x: CGFloat
    let y: CGFloat
}

struct LineChartProvider: Codable {
    
    let data: [Point]
    var lineRadius: CGFloat = 0.5

    private var maxY: CGFloat {
        data.max { $0.y < $1.y }?.y ?? 0
    }
    
    private var minY: CGFloat {
        data.min { $0.y < $1.y }!.y
    }

    private var maxX: CGFloat {
        data.max { $0.x < $1.x }?.x ?? 0
    }
    
    private var yStartingPoint: CGFloat {
        (1 - (data[0].y - minY) / (maxY - minY))
    }
    

    // Creates the line
    func path(for geometry: GeometryProxy) -> Path {
        Path { path in

            path.move(to: .init(x: 0, y: yStartingPoint * geometry.size.height))
            drawData(data, path: &path, size: geometry.size)
        }
    }

    // Creates the gradient
    func closedPath(for geometry: GeometryProxy) -> Path {
        Path { path in
            
            path.move(to: .init(x: 0, y: geometry.size.height))
            drawData(data, path: &path, size: geometry.size)

            path.addLine(to: .init(x: geometry.size.width, y: geometry.size.height))
            path.closeSubpath()
        }
    }

    private func drawData(_ data: [Point], path: inout Path, size: CGSize) {
        
        var previousPoint = Point(x: 0, y: yStartingPoint * size.height)

        self.data.forEach { point in
            
            let xPosition = (point.x / self.maxX) * size.width
//            let yPosition = size.height - (point.y / self.maxY) * size.height
            
            let yAxis = maxY - minY
            let yPosition = (1 - (point.y - minY) / yAxis) * size.height
            let deltaX = xPosition - previousPoint.x
            let curveXOffset = deltaX * self.lineRadius

            path.addCurve(to: .init(x: xPosition, y: yPosition),
                          control1: .init(x: previousPoint.x + curveXOffset, y: previousPoint.y),
                          control2: .init(x: xPosition - curveXOffset, y: yPosition ))

            previousPoint = .init(x: xPosition, y: yPosition)
        }
    }
}
