//
//  View+Ext.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/22/23.
//

import Foundation
import SwiftUI

// Styles background of the Onboarding View
extension View {
    func onBoardingBackgroundStyle(colorScheme: ColorScheme) -> some View {
        self
            .background(LinearGradient(colors: [.black.opacity(colorScheme == .dark ? 0.4 : 0.7), .black.opacity(0.0)],
                                       startPoint: .bottomTrailing,
                                       endPoint: .topLeading))
            .background(Color.onboardingBG)
    }
    
    func cardStyle(colorScheme: ColorScheme, height: CGFloat? = nil) -> some View {
        self
            .padding()
            .frame(width: UIScreen.main.bounds.width * 0.9, height: height)
            .background(colorScheme == .dark ? Color.black.opacity(0.35) : Color.white)
            .cornerRadius(20)
    }
}
