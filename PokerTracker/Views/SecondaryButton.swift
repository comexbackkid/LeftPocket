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
                .frame(width: 50, height: 50)
                .foregroundColor(.brandPrimary)
                .shadow(radius: 5)
            
            Image(systemName: "plus")
                .resizable()
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
        }
    }
}

struct SecondaryButton_Previews: PreviewProvider {
    static var previews: some View {
        SecondaryButton()
          
    }
}
