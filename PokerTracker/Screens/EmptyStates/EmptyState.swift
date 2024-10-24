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
                    
                    Image(getScreen(image: image))
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
    
    let image: EmptyStateImageType
    
    enum EmptyStateImageType: String {
        case metrics
        case sessions
        case locations
    }
    
    func getScreen(image: EmptyStateImageType) -> String {
        
        switch image {
        case .metrics:
            return "bargraphvector-transparent"
        case .sessions:
            return "pokerchipsvector-transparent"
        case .locations:
            return "locationvectorart-transparent"
        }
    }
}

struct EmptyState_Previews: PreviewProvider {
    static var previews: some View {
        EmptyState(image: .locations)
    }
}
