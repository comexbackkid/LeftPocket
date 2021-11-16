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
                Image("empty-list")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 100, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .opacity(0.7)
                
                Text("No Sessions")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                Text("Add your first session now!")
                    .opacity(0.7)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .offset(y:-60)
        }
    }
}

struct EmptyState_Previews: PreviewProvider {
    static var previews: some View {
        EmptyState()
    }
}
