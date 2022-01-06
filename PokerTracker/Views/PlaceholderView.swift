//
//  PlaceholderView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 12/17/21.
//

import SwiftUI

struct PlaceholderView: View {
    var body: some View {
        ZStack {
            Color("bgGray")
                .opacity(0.75)
                .frame(height:290)
            
            Image(systemName: "photo")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
        .padding(.bottom)
    }
}

struct PlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceholderView()
    }
}
