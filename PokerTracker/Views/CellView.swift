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
            
            VStack (alignment: .leading) {
                
                Text(pokerSession.location.name)
                    .font(.body)
                    .lineLimit(1)
                
                Text("\(pokerSession.date.dateStyle())")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(pokerSession.profit.accountingStyle())
                .font(.body)
                .bold()
                .foregroundColor(pokerSession.profit > 0 ? .green : .red)
        }
        .padding(10)
    }
}

struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        CellView(pokerSession: MockData.sampleSession)
            .previewLayout(.sizeThatFits)
    }
}
