//
//  RecentSessionsCellView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import SwiftUI

struct CellView: View {
    
    let pokerSession: PokerSession
    
    var body: some View {
        HStack (spacing: 4) {
            
            Image(systemName: "suit.club.fill")
                .imageRowStyle()
            
            VStack (alignment: .leading, spacing: 2) {
                
                Text(pokerSession.location.name)
                    .bodyStyle()
                    .font(.subheadline)
                    .lineLimit(1)
                
                Text("\(pokerSession.date.dateStyle())")
                    .captionStyle()
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(pokerSession.profit.asCurrency())
                .font(.subheadline)
                .bold()
                .foregroundColor(pokerSession.profit > 0 ? .green : .red)
        }
        .padding(10)
        .padding(.vertical, 4)
        .background(Color.brandBackground)
    }
}

struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        CellView(pokerSession: MockData.sampleSession)
            .previewLayout(.sizeThatFits)
    }
}
