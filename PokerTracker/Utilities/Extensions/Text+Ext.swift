//
//  Text+Ext.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 8/10/22.
//

import Foundation
import SwiftUI

extension Text {
    
    // Common title styling for mimicking Navigation View
    func titleStyle() -> some View {
        self.font(.custom("Asap-Black", size: 34))
            .bold()
            .padding(.bottom, 25)
    }
    
    func signInTitleStyle() -> some View {
        self.font(.custom("Asap-Black", size: 30))
            
    }
    
    func cardTitleStyle() -> some View {
        self.font(.custom("Asap-Bold", size: 23, relativeTo: .title2))
    }
    
    func subtitleStyle() -> some View {
        self.font(.custom("Asap-Bold", size: 21, relativeTo: .title3))
    }
    
    func bodyStyle() -> some View {
        self.font(.custom("Asap-Regular", size: 18, relativeTo: .body))
            .lineSpacing(2.5)
    }
    
    func calloutStyle() -> some View {
        self.font(.custom("Asap-Regular", size: 16, relativeTo: .callout))
    }
    
    func captionStyle() -> some View {
        self.font(.custom("Asap-Regular", size: 12, relativeTo: .caption2))
    }
    
    func subHeadlineStyle() -> some View {
        self.font(.custom("Asap-Regular", size: 15, relativeTo: .subheadline))
    }
    
    func headlineStyle() -> some View {
        self.font(.custom("Asap-Regular", size: 18, relativeTo: .headline))
            .bold()
    }
    
    func buttonTextStyle() -> some View {
        self.font(.custom("Asap-Regular", size: 18))
    }
    
    func bankrollTextStyle() -> some View {
        self.font(.custom("Asap-Black", size: 60))
    }
    
    // Determine if integer is displayed green or red
    func profitColor(total: Int) -> some View {
        self.foregroundColor( total > 0 ? .green : total < 0 ? .red : Color(.systemGray))
    }
}
