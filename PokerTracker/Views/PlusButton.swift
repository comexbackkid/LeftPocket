//
//  PlusButton.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/25/21.
//

import SwiftUI

struct PlusButton: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 40, height: 40)
                .foregroundColor(Color(colorScheme == .dark ? .secondarySystemBackground : .white))
                .shadow(color: .gray.opacity(colorScheme == .dark ? 0.0 : 0.4), radius: 7, x: 0, y: 0)
            
            Image(systemName: "plus")
                .imageScale(.medium)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                
        }
    }
}

struct PlusButton_Previews: PreviewProvider {
    static var previews: some View {
        PlusButton()
            .previewLayout(.sizeThatFits)
    }
}
