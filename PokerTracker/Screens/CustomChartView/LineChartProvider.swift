//
//  ChartProvider.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/28/21.
//

import Foundation
import SwiftUI

struct Point {
    let x: CGFloat
    let y: CGFloat
}

struct LineChartProvider {
    let data: [Point]
    var lineRadius: CGFloat = 0.5

    private var maxYValue: CGFloat {
        data.max { $0.y < $1.y }?.y ?? 0
    }

    private var maxXValue: CGFloat {
        data.max { $0.x < $1.x }?.x ?? 0
    }

    // Creates the line
    func path(for geometry: GeometryProxy) -> Path {
        Path { path in

            path.move(to: .init(x: 0, y: geometry.size.height))

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
        var previousPoint = Point(x: 0, y: size.height)

        self.data.forEach { point in
            let x = (point.x / self.maxXValue) * size.width
            let y = size.height - (point.y / self.maxYValue) * size.height

            let deltaX = x - previousPoint.x
            let curveXOffset = deltaX * self.lineRadius

            path.addCurve(to: .init(x: x, y: y),
                          control1: .init(x: previousPoint.x + curveXOffset, y: previousPoint.y),
                          control2: .init(x: x - curveXOffset, y: y ))

            previousPoint = .init(x: x, y: y)
        }
    }
}
