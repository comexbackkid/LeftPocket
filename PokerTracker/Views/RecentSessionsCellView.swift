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
    
    var currencyFormatter: NumberFormatter {
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = .currency
        numFormatter.maximumFractionDigits = 0
        return numFormatter
    }
    
    var body: some View {
        HStack (spacing: 4) {
            
            Image(systemName: "suit.spade.fill")
                .resizable()
                .frame(width: 18, height: 18)
                .foregroundColor(.white)
                
                .background(
                    Circle()
                        .foregroundColor(Color("brandPrimary"))
                        .frame(width: 36, height: 36, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                )
                .padding(.trailing, 15)
            
            VStack (alignment: .leading) {
                Text(pokerSession.location)
                    .font(.subheadline)
                Text("\(dateFormatter.string(from: pokerSession.date))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(currencyFormatter.string(from: NSNumber(value: pokerSession.profit)) ?? "0")
                .font(.subheadline)
                .bold()
                .foregroundColor(pokerSession.profit > 0 ? .green : .red)
        }
        .padding(8)
    }
}

struct RecentSessionsCellView_Previews: PreviewProvider {
    static var previews: some View {
        RecentSessionsCellView(pokerSession: MockData.sampleSession)
            .previewLayout(.sizeThatFits)
    }
}
