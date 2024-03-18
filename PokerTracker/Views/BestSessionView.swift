//
//  BestSessionView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 12/19/22.
//

import SwiftUI

struct BestSessionView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let profit: Int
    
    var body: some View {
        
        VStack (spacing: 12) {
            HStack {
                
                Text("Biggest Session")
                    .bodyStyle()
                
                Spacer()
                
                Text(profit.asCurrency())
                    .profitColor(total: profit)
                    .lineLimit(1)
                    .font(.custom("Asap-Regular", size: 18, relativeTo: .body))
                    .lineSpacing(2.5)
                    
            }
        }
        .font(.subheadline)
        .padding(30)
        .frame(width: UIScreen.main.bounds.width * 0.9, height: 60)
        .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 5)
        
    }
}

struct BestSessionView_Previews: PreviewProvider {
    static var previews: some View {
        BestSessionView(profit: 1200)
    }
}
