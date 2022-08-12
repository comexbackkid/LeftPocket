//
//  Images+Ext.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 8/12/22.
//

import Foundation
import SwiftUI

extension Image {
    
    func imageRowStyle() -> some View {
        self.resizable()
            .frame(width: 18, height: 18)
            .foregroundColor(.white)
            .background(
                Circle()
                    .foregroundColor(.brandPrimary)
                    .frame(width: 36, height: 36, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            )
            .padding(.trailing, 15)
    }
}
