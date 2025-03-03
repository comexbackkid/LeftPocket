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
    let premium: Bool?
    
    init(title: String, description: String, image: String, color: Color, premium: Bool? = nil) {
        self.title = title
        self.description = description
        self.image = image
        self.color = color
        self.premium = premium
    }
    
    var body: some View {
        
        ZStack {
            
            HStack (alignment: .top) {
                
                Image(systemName: image)
                    .resizable()
                    .bold()
                    .foregroundStyle(Color.black)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .padding(12)
                    .background(color)
                    .cornerRadius(12)
                    
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 12)
//                            .stroke(.primary, lineWidth: 1)
//                    )
//                    .opacity(0.4)
                    
                VStack (alignment: .leading, spacing: 3) {
                    
                    HStack (alignment: .center, spacing: 5) {
                        Text(title)
                            .headlineStyle()
                        
                        if premium == true {
                            Image(systemName: "lock.fill")
                                .font(.footnote)
                            
                        } else {
                            Text("›")
                                .headlineStyle()
                        }
                    }
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
        .frame(width: 300, height: 100)
        .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
    }
}

struct AdditionalMetricsCardView_Previews: PreviewProvider {
    static var previews: some View {
        AdditionalMetricsCardView(title: "Annual Summary", description: "Review results from last year", image: "list.clipboard", color: .lightGreen)
            .preferredColorScheme(.dark)
    }
}
