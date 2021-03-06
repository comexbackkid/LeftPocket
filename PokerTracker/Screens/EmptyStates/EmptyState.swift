//
//  EmptyState.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 9/17/21.
//

import SwiftUI

struct EmptyState: View {
    var body: some View {
        
        ZStack {
            VStack (alignment: .center, spacing: 5) {
                ZStack {
                    
                    Circle()
                        .foregroundColor(.gray)
                        .opacity(0.3)
                        .frame(width: 110, height: 110)
                    
                    Image(systemName: "suit.club.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.white)
                }
                
                Text("No Sessions")
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                Text("Click the + button to get started!")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
        }
    }
}

struct EmptyState_Previews: PreviewProvider {
    static var previews: some View {
        EmptyState()
    }
}
