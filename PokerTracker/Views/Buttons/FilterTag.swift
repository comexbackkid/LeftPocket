//
//  FilterTag.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 10/14/24.
//

import SwiftUI

struct FilterTag: View {
    
    let type: String
    let filterName: String
    
    var body: some View {
        
        HStack {
            Text("\(type):" + "\(filterName)")
                .captionStyle()
        }
        .frame(height: 20)
        .padding(.horizontal, 20)
        .background(Color.secondary)
        .clipShape(.capsule)
        .dynamicTypeSize(.large)
    }
}

#Preview {
    FilterTag(type: "Filter", filterName: "2024")
        .preferredColorScheme(.dark)
}
