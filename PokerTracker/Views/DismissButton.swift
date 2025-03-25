//
//  DismissButton.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 9/11/21.
//

import SwiftUI

struct DismissButton: View {
    
    var body: some View {
        
        ZStack {
            
            Circle()
                .frame(width: 33, height: 33)
                .foregroundColor(.white)
                .opacity(0.6)
            
            Image(systemName: "xmark")
                .imageScale(.medium)
                .fontWeight(.black)
                .frame(width: 44, height: 44)
                .foregroundColor(.black)
        }
    }
}

struct DismissButton_Previews: PreviewProvider {
    static var previews: some View {
        DismissButton()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}
