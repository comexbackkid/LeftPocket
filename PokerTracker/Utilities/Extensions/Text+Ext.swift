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
        self.font(.largeTitle)
            .bold()
            .padding(.leading)
            .padding(.bottom, 8)
            .padding(.top, 40)
    }
    
    // Common styling for mimicking Navigation View
    func subtitleStyle() -> some View {
        self.font(.callout)
            .foregroundColor(.secondary)
            .padding(.horizontal)
            .padding(.bottom, 40)
    }
    
    // Green or Red
    func profitColor(total: Int) -> some View {
        self.foregroundColor( total > 0 ? .green : total < 0 ? .red : Color(.systemGray))
    }
}
