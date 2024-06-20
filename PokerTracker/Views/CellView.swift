//
//  RecentSessionsCellView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import SwiftUI

struct CellView: View {
    
    let pokerSession: PokerSession
    let currency: CurrencyType
    
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
                    HStack (alignment: .firstTextBaseline, spacing: 0) {
                        Text("\(pokerSession.date.dateStyle())" + " • ")
                            .captionStyle()
                            .foregroundColor(.secondary)
                        
                        Text("$" + pokerSession.stakes + " • ")
                            .captionStyle()
                            .foregroundColor(.secondary)
                        
                        Text(pokerSession.game)
                            .captionStyle()
                            .foregroundColor(.secondary)
                    }
                    .lineLimit(1)
                }
            }
            
            Spacer()
            
            Text(pokerSession.profit, format: .currency(code: currency.rawValue).precision(.fractionLength(0)))
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
        CellView(pokerSession: MockData.sampleSession, currency: .EUR, viewStyle: .constant(.standard))
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}
