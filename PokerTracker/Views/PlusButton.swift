//
//  PlusButton.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/25/21.
//

import SwiftUI

struct PlusButton: View {
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 40, height: 40)
                .foregroundColor(Color("brandWhite"))
            
            Image(systemName: "plus")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color("brandBlack"))
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
