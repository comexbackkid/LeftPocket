//
//  RecentSessionsCellView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import SwiftUI

struct CellView: View {
    
    let pokerSession: PokerSession
    
    @Binding var viewStyle: ViewStyle
    
    var body: some View {
        HStack (spacing: 4) {
            
            if viewStyle == .standard {
                Image(systemName: "suit.club.fill")
                    .imageRowStyle()
            }
            
            VStack (alignment: .leading, spacing: 2) {
                
                Text(pokerSession.location.name)
                    .bodyStyle()
                    .lineLimit(1)
                
                if viewStyle == .standard {
                    Text("\(pokerSession.date.dateStyle())")
                        .captionStyle()
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(pokerSession.profit.asCurrency())
                .font(.subheadline)
                .bold()
                .foregroundColor(pokerSession.profit > 0 ? .green : .red)
        }
        .padding(viewStyle == .compact ? 5 : 10)
        .padding(.vertical, viewStyle == .compact ? 0 : 3)
        .background(Color.brandBackground)
    }
}

struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        CellView(pokerSession: MockData.sampleSession, viewStyle: .constant(.standard))
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}
