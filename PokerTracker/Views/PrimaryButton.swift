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
            .buttonTextStyle()
            .frame(height: 52)
            .frame(width: UIScreen.main.bounds.width * 0.9)
            .background(Color.brandPrimary)
            .foregroundColor(.white)
            .cornerRadius(30)
            .padding()
    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryButton(title: "Primary Button")
            .previewLayout(.sizeThatFits)
    }
}
