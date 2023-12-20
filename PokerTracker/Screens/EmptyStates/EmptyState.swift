//
//  EmptyState.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 9/17/21.
//

import SwiftUI

struct EmptyState: View {
    
    let screen: EmptyStateScreenType
    
    enum EmptyStateScreenType: String {
        case metrics
        case sessions
        case locations
    }
    
    func getScreen(screen: EmptyStateScreenType) -> String {
        
        switch screen {
        case .metrics:
            return "bargraphvector-transparent"
        case .sessions:
            return "pokerchipsvector-transparent"
        case .locations:
            return "locationvectorart-transparent"
        }
    }
    
    var body: some View {
        
        ZStack {
            
            VStack (alignment: .center, spacing: 5) {
                
                ZStack {
                    
                    Image(getScreen(screen: screen))
                        .resizable()
                        .frame(width: 125, height: 125)
                }
                
                Text("No Sessions")
                    .cardTitleStyle()
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                Text("Click the + to get started!")
                    .foregroundColor(.secondary)
                    .subHeadlineStyle()
            }
            
            .frame(maxWidth: .infinity)
        }
    }
}

struct EmptyState_Previews: PreviewProvider {
    static var previews: some View {
        EmptyState(screen: .locations)
    }
}
