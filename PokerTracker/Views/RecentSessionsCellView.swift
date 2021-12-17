//
//  RecentSessionsCellView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import SwiftUI

struct RecentSessionsCellView: View {
    
    let pokerSession: PokerSession
    
    var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }
    
    var body: some View {
        HStack (spacing: 4) {
            
            Image(systemName: "suit.spade.fill")
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
                Text("\(dateFormatter.string(from: pokerSession.date))")
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

struct RecentSessionsCellView_Previews: PreviewProvider {
    static var previews: some View {
        RecentSessionsCellView(pokerSession: MockData.sampleSession)
            .previewLayout(.sizeThatFits)
    }
}
