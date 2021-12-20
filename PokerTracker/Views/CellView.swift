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
                .resizable()
                .frame(width: 18, height: 18)
                .foregroundColor(.white)
                .background(
                    Circle()
                        .foregroundColor(.brandPrimary)
                        .frame(width: 36, height: 36, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                )
                .padding(.trailing, 15)
            
            VStack (alignment: .leading) {
                Text(pokerSession.location.name)
                    .font(.body)
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
