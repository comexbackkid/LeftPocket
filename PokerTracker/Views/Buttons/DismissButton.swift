//
//  DismissButton.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 9/11/21.
//

import SwiftUI

struct DismissButton: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        ZStack {
            
            Circle()
                .frame(width: 33, height: 33)
                .foregroundColor(colorScheme == .light ? .white : .black)
                .opacity(colorScheme == .light ? 0.5 : 0.4)
            
            Image(systemName: "xmark")
                .imageScale(.medium)
                .fontWeight(.black)
                .frame(width: 44, height: 44)
                .foregroundStyle(colorScheme == .light ? .black : .white)
        }
    }
}

struct DismissButton_Previews: PreviewProvider {
    static var previews: some View {
        DismissButton()
            .previewLayout(.sizeThatFits)
//            .preferredColorScheme(.dark)
    }
}
