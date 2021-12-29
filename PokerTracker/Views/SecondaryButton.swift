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
                .frame(width: 55, height: 55)
                .foregroundColor(.brandPrimary)
                .shadow(radius: 5)
            
            Image(systemName: "plus")
                .imageScale(.medium)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
        }
    }
}

struct SecondaryButton_Previews: PreviewProvider {
    static var previews: some View {
        SecondaryButton()
          
    }
}
