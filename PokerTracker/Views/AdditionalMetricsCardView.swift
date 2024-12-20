//
//  AdditionalMetricsCardView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/10/23.
//

import SwiftUI

struct AdditionalMetricsCardView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let title: String
    let description: String
    let image: String
    let color: Color
    
//    var body: some View {
        
//        ZStack {
//            VStack {
//                
//                HStack {
//                    
//                    VStack (alignment: .leading, spacing: 3) {
//                        
//                        Text(title)
//                            .cardTitleStyle()
//                            .font(.title2)
//                            .foregroundColor(.white)
//                        
//                        Text(description)
//                            .captionStyle()
//                            .font(.caption)
//                            .foregroundColor(.white)
//                            .opacity(0.8)
//                    }
//                    
//                    Spacer()
//                }
//                .padding(20)
//                
//                Spacer()
//            }
//        }
//        .frame(width: 300, height: 120)
//        .background(
//            HStack {
//                Spacer()
//                Image(systemName: image)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 180, height: 200)
//                    .offset(x: 0, y: 30)
//                    .rotationEffect(Angle(degrees: -30))
//                    .foregroundColor(.white.opacity(0.15))
//            }
//        )
//        .background(LinearGradient(colors: [.black, color.opacity(2.5)], startPoint: .bottomTrailing, endPoint: .topLeading))
//        .cornerRadius(15)
//    }
    
    var body: some View {
        
        ZStack {
            
            HStack (alignment: .top) {
                
                Image(systemName: image)
                    .resizable()
                    .bold()
                    .foregroundStyle(color.gradient)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 38, height: 38)
                    .padding(14)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.primary, lineWidth: 1)
                    )
                    .opacity(0.4)
                    
                VStack (alignment: .leading, spacing: 3) {
                    
                    Text(title + " ›")
                        .headlineStyle()
                        .font(.title2)
                        .lineLimit(1)
                    
                    Text(description)
                        .captionStyle()
                        .font(.caption)
                        .opacity(0.8)
                        .lineLimit(3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 8)
                
                Spacer()
            }
            .padding(18)
        }
        .frame(width: 300, height: 120)
        .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
    }
}

struct AdditionalMetricsCardView_Previews: PreviewProvider {
    static var previews: some View {
        AdditionalMetricsCardView(title: "Annual Summary", description: "Review results and stats for a given year.", image: "list.clipboard", color: .lightGreen)
            .preferredColorScheme(.dark)
    }
}
