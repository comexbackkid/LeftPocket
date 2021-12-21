//
//  HeaderView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/9/21.
//

import SwiftUI

struct HeaderView: View {
    
    @Binding var activeSheet: Sheet?

    var body: some View {
        HStack {
            
            Spacer()
            
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                activeSheet = .newSession
            }, label: {
                PlusButton()
            })
        }
        .padding()
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(activeSheet: .constant(.newSession))
    }
}
