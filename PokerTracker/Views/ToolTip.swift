//
//  ToolTip.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/13/25.
//

import SwiftUI

struct ToolTipView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let image: String
    let message: String
    let color: Color
    let premium: Bool?
    let isLink: Bool?
    
    init(image: String, message: String, color: Color, premium: Bool? = nil, isLink: Bool? = nil) {
        self.image = image
        self.message = message
        self.color = color
        self.premium = premium
        self.isLink = isLink
    }
    
    var body: some View {
        
        HStack {
            
            Image(systemName: image)
                .foregroundColor(color)
                .font(.system(size: 25, weight: .bold))
                .padding(.trailing, 10)
                .frame(width: 40)
            
            Text(message)
                .calloutStyle()
                .blur(radius: premium == true ? 3 : 0)
                .padding(.trailing, isLink == true ? 25 : 0)
            
            Spacer()
            
        }
        .padding(20)
        .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
    }
}

#Preview {
    ToolTipView(image: "clock", message: "Dude, you need to play longer so you stop sucking at poker!", color: .blue)
}
