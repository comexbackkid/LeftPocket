//
//  ShareButton.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 6/16/24.
//

import SwiftUI

struct ShareButton: View {
    
    var body: some View {
        
        ZStack {
            
            Circle()
                .frame(width: 33, height: 33)
                .foregroundColor(.white)
                .opacity(0.6)
            
            Image(systemName: "paperplane.fill")
                .imageScale(.small)
                .fontWeight(.bold)
                .frame(width: 44, height: 44)
                .foregroundColor(.black)
        }
    }
}

#Preview {
    ShareButton()
        .preferredColorScheme(.dark)
}
