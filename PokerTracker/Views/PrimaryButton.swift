//
//  PrimaryButton.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 9/17/21.
//

import SwiftUI

struct PrimaryButton: View {
    
    let title: String
    
    var body: some View {
        
        Text(title)
            .font(.title3)
            .frame(height: 60)
            .frame(width: UIScreen.main.bounds.width * 0.9)
            .background(Color.brandPrimary)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding()
    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryButton(title: "Fake Button")
            .previewLayout(.sizeThatFits)
    }
}
