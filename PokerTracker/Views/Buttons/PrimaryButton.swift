//
//  PrimaryButton.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 9/17/21.
//

import SwiftUI

struct PrimaryButton: View {
    
    let title: LocalizedStringResource
    let color: Color?
    
    init(title: LocalizedStringResource, color: Color? = nil) {
        self.title = title
        self.color = color
    }
    
    var body: some View {
        
        Text(title)
            .buttonTextStyle()
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(color ?? Color.brandPrimary)
            .foregroundColor(.white)
            .cornerRadius(30)
            .padding(.vertical)
    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryButton(title: "Primary Button")
            .previewLayout(.sizeThatFits)
            .environment(\.locale, Locale(identifier: "PT"))
    }
}
