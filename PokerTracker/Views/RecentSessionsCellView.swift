//
//  RecentSessionsCellView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import SwiftUI

struct RecentSessionsCellView: View {
    
    let pokerSession: PokerSession
    
    var body: some View {
        HStack {
            VStack (alignment: .leading) {
                Text(pokerSession.location)
                    .font(.title3)
                Text(pokerSession.stakes + " " + pokerSession.game)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("$" + String(pokerSession.profit))
                .bold()
                .foregroundColor(.green)
          
        }
        .padding(8)
    }
}

struct RecentSessionsCellView_Previews: PreviewProvider {
    static var previews: some View {
        RecentSessionsCellView(pokerSession: MockData.sampleSession)
    }
}
