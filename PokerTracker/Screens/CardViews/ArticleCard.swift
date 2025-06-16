//
//  ArticleCard.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 6/16/25.
//

import SwiftUI

struct ArticleCard: View {
    
    @Environment(\.colorScheme) var colorScheme
    let image: String
    let title: String
    let subtitle: String
    
    var body: some View {
        
        ZStack (alignment: .leading) {
            
            VStack (alignment: .leading) {

                VStack {
                    Image(image)
                        .centerCropped()
                        .overlay {
                            LinearGradient(colors: [.black, .clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                                .opacity(0.2)
                        }
                }
                .frame(maxHeight: 250)
                .clipped()
                
                Spacer()
                
                HStack {
                    
                    VStack (alignment: .leading, spacing: 5) {
                        
                        Text(title)
                            .headlineStyle()
                            .lineLimit(1)
                            .foregroundStyle(.white)
                        
                        Text(subtitle)
                            .calloutStyle()
                            .opacity(0.7)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        
                    }
                    .padding()
                    .padding(.top, -8)
                    .dynamicTypeSize(...DynamicTypeSize.large)
                    
                    Spacer()
                }
                
                Spacer()
            }
            .background(
                ZStack {
                    Image(image)
                        .blur(radius: 20)
                        .overlay(colorScheme == .dark ? .thinMaterial : .ultraThinMaterial)
                }
            )
            
            VStack (alignment: .leading) {
                
                Text("STUDY")
                    .font(.headline)
                    .foregroundColor(.white).opacity(0.5)
                
                Text("Positive Poker")
                    .signInTitleStyle()
                    .fontWeight(.heavy)
                    .foregroundColor(Color(.white))
                
                Spacer()
            }
            
            .padding()
                
        }
        .frame(height: 300)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
    }
}

#Preview {
    ArticleCard(image: "meditation-beach", title: "This is Title", subtitle: "More subtitle text goes here, it's kind of long so here ya go.")
}
