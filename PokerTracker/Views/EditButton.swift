//
//  EditButton.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 3/30/25.
//

import SwiftUI

struct EditButton: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        ZStack {
            
            Circle()
                .frame(width: 33, height: 33)
                .foregroundColor(colorScheme == .light ? .white : .black)
                .opacity(colorScheme == .light ? 0.5 : 0.4)
            
            Image(systemName: "pencil")
                .imageScale(.small)
                .fontWeight(.bold)
                .frame(width: 44, height: 44)
                .foregroundStyle(colorScheme == .light ? .black : .white)
        }
    }
}

#Preview {
    EditButton()
}
