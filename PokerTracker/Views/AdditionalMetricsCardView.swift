//
//  AdditionalMetricsCardView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/10/23.
//

import SwiftUI

struct AdditionalMetricsCardView: View {
    
    let title: String
    let description: String
    let image: String
    let color: Color
    
    var body: some View {
        ZStack {
            VStack {
                
                HStack {
                    
                    VStack (alignment: .leading, spacing: 3) {
                        
                        Text(title)
                            .cardTitleStyle()
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text(description)
                            .captionStyle()
                            .font(.caption)
                            .foregroundColor(.white)
                            .opacity(0.8)
                    }
                    
                    Spacer()
                }
                .padding(20)
                
                Spacer()
            }
        }
        .frame(width: 300, height: 120)
        .background(
            HStack {
                Spacer()
                Image(systemName: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 180, height: 200)
                    .offset(x: 0, y: 30)
                    .rotationEffect(Angle(degrees: -30))
                    .foregroundColor(.white.opacity(0.15))
            }
        )
        .background(LinearGradient(colors: [.black, color], startPoint: .bottomTrailing, endPoint: .topLeading))
        .cornerRadius(15)
    }
}

struct AdditionalMetricsCardView_Previews: PreviewProvider {
    static var previews: some View {
        AdditionalMetricsCardView(title: "Annual Summary", description: "Review results and stats for a \ngiven year.", image: "list.clipboard", color: .blue)
    }
}
