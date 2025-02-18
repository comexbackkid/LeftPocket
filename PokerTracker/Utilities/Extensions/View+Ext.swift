//
//  View+Ext.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/22/23.
//

import Foundation
import SwiftUI

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
            .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
            .cornerRadius(12)
    }
    
    func cardShadow(colorScheme: ColorScheme) -> some View {
        self
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
    }
    
    func snapshot() -> UIImage? {
        let controller = UIHostingController(rootView: self.ignoresSafeArea().fixedSize(horizontal: true, vertical: true))
        
        guard let view = controller.view else { return nil }

        let targetSize = view.intrinsicContentSize // to capture entire scroll content
        if targetSize.width <= 0 || targetSize.height <= 0 { return nil }

        view.bounds = CGRect(origin: .zero, size: targetSize)
        view.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { rendereContext in
            view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
