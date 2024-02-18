//
//  Images+Ext.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 8/12/22.
//

import Foundation
import SwiftUI

extension Image {
    
    // Session List View styling the club logo
    func imageRowStyle() -> some View {
        self
            .resizable()
            .frame(width: 18, height: 18)
            .foregroundColor(.white)
            .background(
                Circle()
                    .foregroundColor(.brandPrimary)
                    .frame(width: 36, height: 36, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            )
            .padding(.trailing, 15)
    }
    
    // Used in Session Detail View
    func detailViewStyle() -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 290)
            .clipped()
            .padding(.bottom)
    }
    
    func locationGridThumbnail(colorScheme: ColorScheme) -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 160, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white, lineWidth: 4))
            .shadow(color: .gray.opacity(colorScheme == .light ? 0.5 : 0.0), radius: 7)
    }
}
