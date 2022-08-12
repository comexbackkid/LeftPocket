//
//  Text+Ext.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 8/10/22.
//

import Foundation
import SwiftUI

extension Text {
    
    func titleStyle() -> some View {
        self.font(.largeTitle)
            .bold()
            .padding(.leading)
            .padding(.bottom, 8)
            .padding(.top, 40)
    }
    
    func subtitleStyle() -> some View {
        self.font(.callout)
            .foregroundColor(.secondary)
            .padding(.horizontal)
            .padding(.bottom, 40)
    }
}
