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
                .foregroundColor(Color("brandWhite"))
                .shadow(color: .gray.opacity(0.3), radius: 6, x: 0, y: 0)
            
            Image(systemName: "plus")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .frame(width: 20, height: 20)
        }
    }
}

struct PlusButton_Previews: PreviewProvider {
    static var previews: some View {
        PlusButton()
            .previewLayout(.sizeThatFits)
    }
}
