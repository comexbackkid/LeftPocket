//
//  AdditionalMetricsCardView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/10/23.
//

import SwiftUI

struct AdditionalMetricsCardView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let title: LocalizedStringResource
    let description: String
    let image: String
    let color: Color
    let premium: Bool?
    
    init(title: LocalizedStringResource, description: String, image: String, color: Color, premium: Bool? = nil) {
        self.title = title
        self.description = description
        self.image = image
        self.color = color
        self.premium = premium
    }
    
    var body: some View {
        
        ZStack {
            
            HStack (alignment: .top) {
                    
                VStack (alignment: .leading, spacing: 3) {
                    
                    Image(systemName: image)
                        .resizable()
                        .bold()
                        .foregroundStyle(color)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .padding(.bottom, 8)
                    
                    HStack (alignment: .center, spacing: 5) {
                        Text(title)
                            .font(.custom("Asap-Bold", size: 16))
                        
                        if premium == true {
                            Image(systemName: "lock.fill")
                                .font(.footnote)
                        }
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    
                    Text(description)
                        .captionStyle()
                        .opacity(0.8)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            .padding(18)
        }
        .frame(width: 190)
        .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
    }
}

struct AdditionalMetricsCardView_Previews: PreviewProvider {
    static var previews: some View {
        AdditionalMetricsCardView(title: "Tournament Report", description: "Advances stats", image: "person.2.fill", color: .red)
//            .preferredColorScheme(.dark)
    }
}
