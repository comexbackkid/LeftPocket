//
//  Onboarding.progressAnimation.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/13/25.
//

import SwiftUI

struct ProgressAnimation: View {
    
    @State private var drawingWidth = false

    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {

            ZStack(alignment: .leading) {
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray).opacity(0.25))
                    .frame(height: 12)

                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.lightGreen.gradient)
                        .frame(width: drawingWidth ? geo.size.width : 0, height: 12)
                        .animation(.easeInOut(duration: 5), value: drawingWidth)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12)) // Mask to prevent overflow
            }
            .frame(height: 12)
        }
        .padding(.horizontal, 20)
        .onAppear {
            drawingWidth = true
        }
    }
}
