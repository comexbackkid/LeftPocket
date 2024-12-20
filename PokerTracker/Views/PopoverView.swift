//
//  PopoverView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 6/13/24.
//

import SwiftUI

struct PopoverView: View {
    
    let bodyText: String
    
    var body: some View {
        
        VStack (spacing: 0) {
            
            Image(systemName: "info.circle")
                .foregroundStyle(Color.brandPrimary)
                .font(.title3)
            
            Text(bodyText)
                .calloutStyle()
                .multilineTextAlignment(.leading)
                .padding(10)
            
        }
        .padding(10)
        .font(.subheadline)
    }
}

#Preview {
    PopoverView(bodyText: "This is where the somewhat lengthy popover tip text is displayed to the user.")
}
