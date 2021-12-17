//
//  SecondaryButton.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/19/21.
//

import SwiftUI

struct SecondaryButton: View {

    var body: some View {
            
        ZStack {
            Circle()
                .frame(width: 60, height: 60)
                .foregroundColor(.brandPrimary)
                .shadow(radius: 5)
            
            Image(systemName: "plus")
                .resizable()
                .foregroundColor(Color("brandWhite"))
                .frame(width: 28, height: 28)
        }
    }
}


struct SecondaryButton_Previews: PreviewProvider {
    static var previews: some View {
        SecondaryButton()
          
    }
}
